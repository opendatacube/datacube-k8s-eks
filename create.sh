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
# rm -rf .terraform
# terraform init -backend-config workspaces/$WORKSPACE/backend.cfg infra
# terraform plan -input=false -var-file="workspaces/$1/terraform.tfvars" infra
# terraform apply -auto-approve -input=false -var-file="workspaces/$1/terraform.tfvars" infra

# build blue worker nodes

rm -rf .terraform
terraform init -backend-config workspaces/$WORKSPACE/backend.cfg nodes
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform plan -input=false -var-file="workspaces/$1/terraform.tfvars" nodes
terraform apply -auto-approve -input=false -var-file="workspaces/$1/terraform.tfvars" nodes



