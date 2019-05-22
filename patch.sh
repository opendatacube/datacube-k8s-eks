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

if [ -z $3 ]; then
    echo "No new AMI specified, cannot update workers"
    exit 1
fi

function fail_on_workspace {
    echo "$1 does not exist, please ensure apply.sh has been run"
    exit 1
}

export WORKSPACE=$1
export WORKSPACESPATH=$2

# build worker nodes
pushd nodes
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
terraform workspace select "$WORKSPACE-green" || fail_on_workspace "$WORKSPACE-green"
terraform workspace select "$WORKSPACE-blue" || fail_on_workspace "$WORKSPACE-blue"

blue_enabled=$(terraform output enabled)
active_node_group=$([[ "$blue_enabled" = "true" ]] && echo "blue" || echo "green")
new_node_group=$([[ "$active_node_group" == "blue" ]] && echo "green" || echo "blue")

# Create new nodes
terraform workspace select "$WORKSPACE-$new_node_group"
terraform apply -auto-approve -input=false \
    -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" \
    -var group_enabled=true \
    -var node_group_name="$new_node_group" \
    -var ami_image_id="$3"

# Drain current nodes
../drain_and_wait.sh "$active_node_group"

# Destroy old nodes
terraform workspace select "$WORKSPACE-$active_node_group"
terraform apply -auto-approve -input=false \
    -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" \
    -var group_enabled=false \
    -var node_group_name="$active_node_group" 
popd
