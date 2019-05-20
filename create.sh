#!/bin/bash

set -e
#set -o xtrace
# 
# Patch EKS nodes
# 

if [ -z $1 ]; then
    echo "Error: cluster variable is not set, I don't know which cluster you want to create"
    exit 1
fi

export WORKSPACE=$1

# build network and EKS masters
pushd infra
rm -rf .terraform
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform apply -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 

# Configure local kubernetes config
aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)

# Set up aws-auth
popd

# build worker nodes
pushd nodes
rm -rf .terraform
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform apply -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 
popd

pushd infra

popd

pushd addons
rm -rf .terraform
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-addons" || terraform workspace select "$WORKSPACE-addons"
terraform apply -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 
popd
