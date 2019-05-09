#!/bin/bash

set -e
#set -o xtrace
# 
# Patch EKS nodes
# 

if [ -z $1 ]; then
    echo "Error: cluster variable is not set, I don't know which cluster you want to patch"
    exit 1
fi

# ensure we have a clean terraform environment
rm -rf .terraform
terraform init -backend-config workspaces/$1/backend.cfg

# ask terraform what the current nodegroup is
current_nodegroup=`terraform output current_nodegroup || ''`

#
# Patch the cluster if it exists
#
if [ -z "$current_nodegroup" ] || [ "$2" == "--no-patch" ]; then
    echo "Info: Creating cluster"

    #
    # Create the cluster if it doesn't exist
    #
    terraform apply -auto-approve -input=false -var-file="workspaces/$1/terraform.tfvars" \
    -var 'blue_nodes_enabled=0' \
    -var 'green_nodes_enabled=1'

    # Configure local kubernetes config
    terraform output kubeconfig > ~/.kube/config-eks
    terraform output cluster_defaults > cluster_defaults.yaml


    export OLD_KUBECONFIG=$KUBECONFIG
    export KUBECONFIG="$HOME/.kube/config-eks"
    kubectl config get-contexts -o name
    kubectl config use-context aws

    # Set up aws-auth
    terraform output config_map_aws_auth > aws-auth.yaml
    terraform output database_credentials > db-creds.yaml

    kubectl apply -f aws-auth.yaml
    kubectl apply -f db-creds.yaml
    kubectl apply -f tiller.yaml

    # add datcube.local to dns
    terraform output coredns_config > coredns_config.yaml
    kubectl apply -f coredns_config.yaml
    dns_pods=( $( kubectl get pods -o name -n kube-system | grep coredns | cut -d'/' -f 2 ) ) 
    for pod in "${dns_pods[@]}"
    do
        # Reload without outage
        kubectl exec -n kube-system $pod -- kill -SIGUSR1 1  
    done

    helm init --service-account tiller --wait

    # create datacube database

elif [ "$current_nodegroup" == "green" ] || [ "$current_nodegroup" == "blue" ];then
    echo "Info: Current nodegroup is $current_nodegroup"

    # Disable cluster autoscaler, so we don't scale whilst patching
    kubectl scale deployments/cluster-autoscaler-aws-cluster-autoscaler --replicas=0 -n kube-system || echo 'Warning: cluster autoscaler not found'

    # Check the current ami
    suffix='_ami_image_id'
    current_image=`terraform output $current_nodegroup$suffix || ''`

    # create a second nodegroup (ensure the original one keeps the ami id)
    terraform apply -auto-approve -input=false -var-file="workspaces/$1/terraform.tfvars" \
    -var 'blue_nodes_enabled=1' \
    -var 'green_nodes_enabled=1' \
    -var "$current_nodegroup$suffix=$current_image"

    # Configure local kubernetes config
    terraform output kubeconfig > "$HOME/.kube/config-eks"
    terraform output cluster_defaults > cluster_defaults.yaml

    export OLD_KUBECONFIG=$KUBECONFIG
    export KUBECONFIG="$HOME/.kube/config-eks"
    kubectl config get-contexts -o name
    kubectl config use-context aws

    # Remove any existing taints from failed patch runs 
    kubectl taint nodes --all=true key:NoSchedule- || echo "Removed Taints"

    # taint the existing nodegroup so no new pods will schedule
    kubectl taint nodes -l nodegroup=$current_nodegroup key=value:NoSchedule --overwrite=true

    # ensure we have 2 dns pods running
    kubectl scale deployments/coredns --replicas=2 -n kube-system

    # Safely drain each node in the group
    nodes=($(kubectl get nodes -l nodegroup=$current_nodegroup -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'))
    for i in "${nodes[@]}"
    do
        echo "Draining node: $i"
        kubectl drain $i --ignore-daemonsets --delete-local-data || echo "Node $i no longer exists"

        # Wait max 15 mins deployments to be healthy
        max_wait=900
        ready=false
        while [[ $max_wait -gt 0 ]] && [ $ready == false ]; do
            # Wait first to ensure the drain has started
            sleep 10
            max_wait=$(($max_wait - 10))
            echo "Waited 10 seconds. Still waiting max. $max_wait"

            # Check if deployments are healthy

            ready=true 
            deployment=($(kubectl get deployments --all-namespaces | tail -n +2 | awk '{print $2}'))
            desired=($(kubectl get deployments --all-namespaces | tail -n +2 | awk '{print $3}'))
            available=($(kubectl get deployments --all-namespaces | tail -n +2 | awk '{print $6}'))
            count="${#deployment[@]}"
            for (( i=0; i<$count; i++ )); do
                if [  "${available[$i]}" -lt "${desired[$i]}" ]; then
                    echo "Deployment ${deployment[$i]} not ready, desired pods: ${desired[$i]}, available pods: ${available[$i]}"
                    ready=false 
                fi
            done
            echo "Deployments ready: $ready"
        done
    done


    # drain all pods from the nodes, continue even if we are using empytyDir 
    kubectl drain -l nodegroup=$nodegroup --ignore-daemonsets --delete-local-data

    # delete original nodegroup
    if [ "$current_nodegroup" == "green" ]; then
        terraform apply -auto-approve -input=false -var-file="workspaces/$1/terraform.tfvars" \
        -var 'blue_nodes_enabled=1' \
        -var 'green_nodes_enabled=0'

    elif [ "$current_nodegroup" == "blue" ]; then
        terraform apply -auto-approve -input=false -var-file="workspaces/$1/terraform.tfvars" \
        -var 'blue_nodes_enabled=0' \
        -var 'green_nodes_enabled=1'
    fi

    # Enable cluster autoscaler
    kubectl scale deployments/cluster-autoscaler-aws-cluster-autoscaler --replicas=1 -n kube-system || echo 'Warning: cluster autoscaler not found'

    new_nodegroup=`terraform output current_nodegroup`

    echo "Info: Worker patching successful, current node_group is now $new_nodegroup"

    echo "setting kubeconfig to previous"
    KUBECONFIG=$OLD_KUBECONFIG
else
    echo "Error: I'm not sure what you want me to do"
    exit 1
fi

set +e
set +o xtrace