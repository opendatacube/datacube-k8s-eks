#! /usr/bin/env bash
set -e

echo "deploying datakube data orchestration $1"

if [ -z $1 ] || [ -z $2 ]; then
    echo "Error: workspace and/or workspaces path variables not set, I don't know which workspace you want to create"
    exit 1
fi

export WORKSPACE=$1
export WORKSPACESPATH=$2

if [[ "$3" = "clean" ]]; then
    CLEAN="true"
fi

if [ ! -z "$CLEAN" ]; then
    rm -rf .terraform
fi

terraform init -backend-config $WORKSPACEPATH/$WORKSPACE/backend.cfg
terraform workspace new "$WORKSPACE-s3-bucket-notification" || terraform workspace select "$WORKSPACE-s3-bucket-notification"
terraform plan -out bucket.plan -input=false \
    -var-file="$WORKSPACEPATH/$WORKSPACE/terraform.tfvars" \
    -var-file="$WORKSPACEPATH/$WORKSPACE/bucket_notifications.terraform.tfvars"
terraform apply -auto-approve bucket.plan
rm bucket.plan
