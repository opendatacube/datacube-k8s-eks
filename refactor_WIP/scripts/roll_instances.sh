#!/bin/bash

# set -e

# shellcheck disable=SC2178,SC2128

# time to wait for deployments to be healthy
wait_limit=${1:-900} # default set to 15 mins
# nodes to patch in a single go
max_nodes=${2:-50} # default set to max 50 nodes

# Helper function that will return the name of the newest instance in the cluster
get-newest-instance-name(){
    name=$(kubectl get nodes -o custom-columns=":metadata.creationTimestamp,:metadata.name" --no-headers | sort -k1 -r | awk '{print $2}' | head -n 1)
    echo "$name"
}

# Helper function that will return the name of the oldest instance in the cluster
get-oldest-instance-name(){
    name=$(kubectl get nodes -o custom-columns=":metadata.name" --sort-by=.metadata.creationTimestamp --no-headers | head -n 1)
    echo "$name"
}

# Helper function that will return the creationTimestamp of the oldest instnce timestamp in the cluster
get-oldest-instance-timestamp(){
    iso=$(kubectl get nodes -o custom-columns=":metadata.creationTimestamp" --sort-by=.metadata.creationTimestamp --no-headers | head -n 1)
    epoch=$(date -d"$iso" +%s)
    echo "$epoch"
}

# Checks all deployments are healthy
wait-for-deployments(){
    # Wait max 15 mins per nodes for deployments to be healthy
    max_wait=$wait_limit
    ready=false
    while [[ $max_wait -gt 0 ]] && [ $ready == false ]; do
        # Check if deployments are healthy

        ready=true
        # deployment: an array of all the deployment names
        mapfile -t deployment < <(kubectl get deployments --all-namespaces -o custom-columns=":metadata.name" --sort-by=.metadata.name --no-headers)
        # available: an array of all available replicas same order as deployment
        mapfile -t available < <(kubectl get deployments --all-namespaces -o custom-columns=":status.availableReplicas" --sort-by=.metadata.name --no-headers)
        # desired: an array of all desired replicas same order as deployment
        mapfile -t desired < <(kubectl get deployments --all-namespaces -o custom-columns=":status.replicas" --sort-by=.metadata.name --no-headers)

        count="${#deployment[@]}"
        for (( i=0; i<count; i++ )); do
            if ! [[ "${desired[$i]}" =~ ^[0-9]+$ ]]; then
                    echo "Warning: Deployment ${deployment[$i]} doesn't have any replicas"
                    continue
            fi
            if [ "${available[$i]}" -lt "${desired[$i]}" ]; then
                echo "Deployment ${deployment[$i]} not ready, desired pods: ${desired[$i]}, available pods: ${available[$i]}"
                ready=false
            fi
        done
        echo "Deployments ready: $ready"

        if [ $ready = false ]; then
            sleep 10
            max_wait=$((max_wait - 10))
            echo "Waited 10 seconds. Still waiting max. $max_wait"
        fi
    done
}

# From a node name, find the ASG the node is hosted in
find-asg(){
    instanceid=$(kubectl get nodes "$1" -o jsonpath='{.metadata.labels.instance-id}')
    asg=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instanceid" "Name=key,Values=aws:autoscaling:groupName" | jq -r '.Tags[0].Value')
    echo "$asg"
}

# Scale up the ASG
scale-up-asg(){
    max=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$1" | jq '.AutoScalingGroups[0].MaxSize')
    desired=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$1" | jq '.AutoScalingGroups[0].DesiredCapacity')
    desired=$((desired+1))
    if [ "$desired" -le "$max" ]; then
        aws autoscaling set-desired-capacity --auto-scaling-group-name "$1" --desired-capacity "$desired"
    else
        echo "Warning: Autoscaling Group at max, cannot scale up prematurely"
    fi
}

# Scale down the ASG (this expects the default settings of removing oldest node are set)
scale-down-asg(){
    min=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$1" | jq '.AutoScalingGroups[0].MinSize')
    desired=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$1" | jq '.AutoScalingGroups[0].DesiredCapacity')
    desired=$((desired-1))
    if [ "$desired" -ge "$min" ]; then
        aws autoscaling set-desired-capacity --auto-scaling-group-name "$1" --desired-capacity "$desired"
    else
        echo "Warning: Autoscaling Group at min, cannot scale down"
    fi
}

echo "Checking deployments are healthy"
wait-for-deployments

if [ $ready = false ]; then
    echo "Deployments not in healthy state"
    # ensure cluster autoscaler is back online
    kubectl scale deployment/cluster-autoscaler-aws-cluster-autoscaler -n cluster-autoscaler --replicas 1
    exit 1
fi

start_time=$(date '+%s')

echo "Starting to patch at time: $start_time"

# ensure we have 2 dns pods running
kubectl scale deployments/coredns --replicas=2 -n kube-system
# disable cluster autoscaler as it messes with stuff
kubectl scale deployment/cluster-autoscaler-aws-cluster-autoscaler -n cluster-autoscaler --replicas 0

node_count=0

# Run until we have patched every node
until [ "$start_time" -lt "$(get-oldest-instance-timestamp)" ]; do

    oldest_node=$(get-oldest-instance-name)
    echo "Draining node $oldest_node"

    # Scale up asg
    asg=$(find-asg "$oldest_node")
    scale-up-asg "$asg"

    # Give it 60 seconds to create a new node
    sleep 60

    # Wait until newest node is ready
    echo "Waiting for newest node to be ready"
    sed '/\sReady/q' <(kubectl get node $(get-newest-instance-name) -w)

    # Taint node with noschedule, then drain the pods off it, if something breaks move on
    kubectl cordon "$oldest_node" && kubectl drain "$oldest_node" --delete-local-data --ignore-daemonsets --force || echo "Warning: node could not be drained, continuing"

    # Wait until all deployments are healthy
    echo "Waiting for deployments to be healthy"
    wait-for-deployments

    # scale down asg
    scale-down-asg "$asg"

    # Remove the node from kubernetes (So we don't keep trying to remove the same node)
    kubectl delete node "$oldest_node"

    node_count=$((node_count+1))
    if [ "$node_count" -ge "$max_nodes" ]; then
        echo "Patched max number of nodes, finishing"
        break
    fi
done

#ensure cluster autoscaler is back online
kubectl scale deployment/cluster-autoscaler-aws-cluster-autoscaler -n cluster-autoscaler --replicas 1
echo "Patching complete, patched $node_count nodes"