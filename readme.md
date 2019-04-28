# Datacube Kubernetes EKS

:warning: This is still a work in progress and doesn't have an official release :warning:

This repository will build and manage a production scale kubernetes cluster using the AWS EKS engine
for running datacube applications.

[![circleci](https://circleci.com/gh/opendatacube/datacube-k8s-eks.svg?style=shield&circle-token=:circle-ci-badge-token)](https://circleci.com/gh/opendatacube/datacube-k8s-eks/tree/master)

---

# Requirements

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://github.com/kubernetes/helm#install)
- [Terraform](https://www.terraform.io/downloads.html)
- [Packer](https://www.packer.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [A Public Route53 Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)
  - This will be used to enable your cluster to talk to itself, and for automatic assignment of application DNS entries.

---

# Deployment steps

## Deploy Kubernetes Cluster
```bash
make init cluster=<cluster name>
make setup cluster=<cluster name>
```

## Create a database
```bash
make create-db name=ows
```
This will leave a helm chart called `ows` that you can adjust the variables for to deploy your datacube apps

## Run index job

```bash
make run-index template=index-s3.yaml"
```

Will run index job defined by nrt.yaml file in jobs/

---

# Deploy Add ons

## Flux

ensure flux is enabled in the config, and has been deployed with `make setup`

```bash
fluxctl identity --k8s-fwd-ns flux
```

copy this and put it in a service account that can write to your flux repo


---

# Maintenance

## Access the cluster

The user that runs the terraform code to create the eks cluster will be given access automatically, if you want to add more users to the cluster you'll need to follow this process 

1. Ensure you have a iam user in the same AWS Account as the cluster
2. Ensure the user has MFA configured
3. Add the user to the config `user = [users/yourname]`

```bash
cd infra
terraform output user_profile
```

add this to the bottom of your `~/.aws/config`
put your user name in the `<your user name>` section


## Patch the worker nodes
```bash
make patch cluster=<cluster name>
```

---

# Troubleshooting

## Pods stuck in unknown state
Sometimes this can happen if you've over provisioned your nodes, set resource limits, and delete the offending pods with: `kubectl delete pods <unknown pods name> --grace-period=0 --force`

## OutOfPods
The networking provided by EKS restricts the number of pods that can be deployed on a single node, increase the minimum number of nodes
