#!/bin/bash
set -o xtrace
# Get instance and ami id from the aws ec2 metadate endpoint
id=$(curl http://169.254.169.254/latest/meta-data/instance-id -s)
ami=$(curl http://169.254.169.254/latest/meta-data/ami-id -s)
/etc/eks/bootstrap.sh --apiserver-endpoint '${endpoint}' --b64-cluster-ca '${certificate_authority}' '${cluster_id}' \
--kubelet-extra-args \
  "--node-labels=cluster=${cluster_id},nodegroup=${node_group},nodetype=${node_type},nodesize=${node_size},instance-id=$id,ami-id=$ami,"hub.jupyter.org/node-purpose=${node_purpose}" \
   --register-with-taints="hub.jupyter.org/dedicated=${node_purpose}:NoSchedule" \
   --cloud-provider=aws"
