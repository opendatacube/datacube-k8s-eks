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
export WORKSPACESPATH=$(realpath $2)

# build network and EKS masters
pushd infra
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 
terraform apply -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 

# Configure local kubernetes config
aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)

# Set up aws-auth
popd

# build worker nodes
pushd nodes
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform apply -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 
popd

pushd addons
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-addons" || terraform workspace select "$WORKSPACE-addons"
terraform apply -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 
popd
