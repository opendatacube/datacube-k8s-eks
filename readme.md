# DataKube

This repository will build and manage a production scale kubernetes cluster
for running datacube applications.

---

# Requirements

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
[Helm](https://github.com/kubernetes/helm#install)
[Terraform](https://www.terraform.io/downloads.html)
[Packer](https://www.packer.io/downloads.html)

## A Publicaly routable Route 53 hosted zone
This will be used to enable your cluster to talk to itself, and for automatic assignment of application DNS entries.

## A service account
```bash
aws iam create-group --group-name kops

aws iam create-group --group-name kops-full

aws iam create-group --group-name kops-custom

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRDSFullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess --group-name kops-full
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonSSMFullAccess  --group-name kops-full

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly --group-name kops

DOCUMENT="{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt"
            ],
            "Resource": "arn:aws:kms:*:*:key/*"
        }
    ]
}"

aws iam create-policy --policy-name KMS_Encrypt_Decrypt --description Encrypt and Decrypt using any KMS Key --policy-document $DOCUMENT

aws iam attach-group-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/KMS_Encrypt_Decrypt --group-name kops-custom

aws iam create-user --user-name kops

aws iam add-user-to-group --user-name kops --group-name kops-full
aws iam add-user-to-group --user-name kops --group-name kops
aws iam add-user-to-group --user-name kops --group-name kops-custom

aws iam create-access-key --user-name kops
```

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
make run-index  template=index-job name=nrt"
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