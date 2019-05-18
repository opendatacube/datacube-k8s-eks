#!/bin/bash

set -e
#set -o xtrace
# 
# Patch EKS nodes
# 

if [ -z $1 ] || [ -z $2 ]; then
    echo "Error: workspace and/or workspaces path variable is not set, I don't know which workspace you want to destroy"
    exit 1
fi

export WORKSPACE=$1
export WORKSPACESPATH=$2

# delete addons
pushd addons
# rm -rf .terraform
# rm -rf terraform.tfstate.d
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-addons" || terraform workspace select "$WORKSPACE-addons"
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 

popd

# delete worker nodes
pushd nodes
# rm -rf .terraform
# rm -rf terraform.tfstate.d
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 

popd

# delete network and EKS masters
pushd infra
# rm -rf .terraform
# rm -rf terraform.tfstate.d 
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 
popd