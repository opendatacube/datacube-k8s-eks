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
terraform plan -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 
terraform apply -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 

# Configure local kubernetes config
aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)

# Set up aws-auth
terraform output config_map_aws_auth > aws-auth.yaml

kubectl apply -f aws-auth.yaml
popd

# build worker nodes
pushd nodes
rm -rf .terraform
terraform init -backend-config ../workspaces/$WORKSPACE/backend.cfg 
terraform workspace new "$WORKSPACE-blue" || terraform workspace select "$WORKSPACE-blue"
terraform plan -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 
terraform apply -auto-approve -input=false -var-file="../workspaces/$WORKSPACE/terraform.tfvars" 

popd
pushd infra
terraform output database_credentials > db-creds.yaml

kubectl apply -f db-creds.yaml
kubectl apply -f tiller.yaml

popd
