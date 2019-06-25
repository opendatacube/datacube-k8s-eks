# Patching & Upgrading

## Upgrading EKS Cluster version
> **WARNING:** Once upgraded, the EKS Cluster version cannot be downgraded in-place. If you wish to downgrade, the cluster must be destroyed and recreated with a previous version.

Terraform can upgrade your EKS cluster in-place to a newer version. This will also create new worker node infrastructure to support the new EKS cluster version and destroy the old worker node infrastructure.

Upgrading your EKS cluster to a newer EKS version update the value of `cluster_version` in your cluster definition [examples/quickstart/workspaces/terraform.tfvars](../examples/quickstart/workspaces/terraform.tfvars) to the EKS version desired. A list of EKS version can be found [here](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html).

Also ensure that the AMI specified by `ami_image_id` is compatible with the desired EKS cluster version. Alternatively `ami_image_id` can be unset, in which case terraform will automatically use a compatible AMI.

Once the cluster definition has been updated run the following to apply the upgrade to your cluster:
> **NOTE:** This may cause an outage during the upgrade when worker nodes are replaced
```bash
make apply workspace=<cluster name> path=<path>
```

## Patching worker nodes
We've set up automated processes to do blue / green patching of your cluster. An AMI which the worker nodes will be upgraded to is required. In order to run the node patching you can run this using the following command:
```bash
make patch workspace=<cluster name> path=<path> ami=<ami>
```
