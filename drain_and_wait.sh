current_nodegroup="$1"

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

    # Wait max 15 mins per nodes for deployments to be healthy
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
kubectl drain -l nodegroup=$current_nodegroup --ignore-daemonsets --delete-local-data