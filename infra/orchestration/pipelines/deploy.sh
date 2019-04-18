#! /usr/bin/env bash
set -e

echo "deploying datakube data container orchestration travis lambda $1"

rm -rf .terraform

# Deploy Network Infrastructure
export WORKSPACE=$1
terraform init -backend-config ../../workspaces/$WORKSPACE/backend.cfg
terraform workspace new "$WORKSPACE-pipelines" || terraform workspace select "$WORKSPACE-pipelines"
terraform plan -input=false -var-file="../../workspaces/$WORKSPACE/terraform.tfvars"
terraform apply -auto-approve -input=false -var-file="../../workspaces/$WORKSPACE/terraform.tfvars"
