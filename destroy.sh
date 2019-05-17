#!/bin/bash

set -e
#set -o xtrace
# 
# Patch EKS nodes
# 

if [ -z $1 ]; then
    echo "Error: cluster variable is not set, I don't know which cluster you want to delete"
    exit 1
fi

export WORKSPACE=$1

# delete addons
pushd addons
rm -rf .terraform
rm -rf terraform.tfstate.d
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-addons" || terraform workspace select "$WORKSPACE-addons"
terraform destroy -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 

popd

# delete worker nodes
pushd nodes
rm -rf .terraform
rm -rf terraform.tfstate.d
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform destroy -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 

popd

# delete network and EKS masters
pushd infra
rm -rf .terraform
rm -rf terraform.tfstate.d 
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform destroy -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 
popd