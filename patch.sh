#!/bin/bash

set -e
#set -o xtrace
# 
# Patch EKS nodes
# 

if [ -z $1 ] || [ -z $2 ]; then
    echo "Error: workspace and/or workspaces path variables not set, I don't know which workspace you want to create"
    exit 1
fi

export WORKSPACE=$1
export WORKSPACESPATH=$2

# build worker nodes
pushd nodes
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
# this is no longer only 'blue' workers nodes, however maintain the $WORKSPACE-blue for backwards compatibility
# with older stacks
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
active_node_group=$(terraform output current_node_group || echo "blue")
new_node_group=$([[ "$active_node_group" == "blue" ]] && echo "green" || echo "blue")
echo $new_node_group
terraform apply -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" -var enabled_groups='["blue", "green"]'
# Drain current node group
../drain_and_wait.sh "$active_node_group"
terraform apply -auto-approve -input=false \
    -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" \
    -var enabled_groups='["'"$new_node_group"'"]' \
    -var current_node_group="$new_node_group"
popd
