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

if [[ "$3" = "clean" ]]; then
    CLEAN="true"
fi

# build network and EKS masters
pushd infra
if [ ! -z "$CLEAN" ]; then
    rm -rf .terraform
fi
# terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
# terraform plan -out infra.plan -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars"
# terraform apply -auto-approve infra.plan
# rm infra.plan

# Configure local kubernetes config
# aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)

# Set up aws-auth
popd

# build worker nodes
pushd nodes
if [ ! -z "$CLEAN" ]; then
    echo "Cleaning"
    rm -rf .terraform
fi
terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg 

terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform plan -out workersblue.plan -input=false \
    -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" \
    -var group_enabled=true \
    -var node_group_name=blue
terraform apply -auto-approve workersblue.plan
rm workersblue.plan

terraform workspace new "$WORKSPACE-green" || terraform workspace select "$WORKSPACE-green"
terraform plan -out workersgreen.plan -input=false \
    -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars" \
    -var group_enabled=false \
    -var node_group_name=green
terraform apply -auto-approve workersgreen.plan
rm workersgreen.plan
popd

# pushd addons
# if [ ! -z "$CLEAN" ]; then
#     rm -rf .terraform
# fi
# terraform init -backend-config $WORKSPACESPATH/$WORKSPACE/backend.cfg
# terraform workspace new "$WORKSPACE-addons" || terraform workspace select "$WORKSPACE-addons"
# terraform plan -out addons.plan -input=false -var-file="$WORKSPACESPATH/$WORKSPACE/terraform.tfvars"
# terraform apply -auto-approve addons.plan
# rm addons.plan
# popd
