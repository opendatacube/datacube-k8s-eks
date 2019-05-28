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

if [[ "$3" = "clean" ]]; then
    CLEAN="true"
fi

# delete addons
pushd addons
if [ ! -z "$CLEAN" ]; then
    rm -rf .terraform
fi
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
terraform workspace new "$WORKSPACE-addons" || terraform workspace select "$WORKSPACE-addons"
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 

popd

# delete worker nodes
pushd nodes
if [ ! -z "$CLEAN" ]; then
    rm -rf .terraform
fi
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars"

terraform workspace new "$WORKSPACE-green" || terraform workspace select "$WORKSPACE-green"
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 

popd

# delete network and EKS masters
pushd infra
if [ ! -z "$CLEAN" ]; then
    echo "cleaning"
    rm -rf .terraform
fi
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
terraform destroy -auto-approve -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" 
popd
