# Service Account

When deploying a long-lived cluster you should use a service account to perform the initial
deployment, as well as any ongoing maintenance. The user that creates the EKS cluster is given
special access to perform changes to the cluster, this helps to avoid any MFA requirements you want
to put on your human admins.

You should set up some automation to deploy this infrastructure using a CI platform, this page will
show you how to generate a service account with the permissions needed to generate the infrastructure.

These permission are an example that work and are roughly the required permissions for successful
deployment. You should tailor these permissions according to your deployment needs and reduce them
further, depending on your cluster configuration.

## Create the service account

To create the service account you'll need to run these commands from the root folder in this repo

```sh
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
aws iam create-group --group-name eks-deployer

aws iam create-policy --policy-name EKSPolicy --policy-document file://eks-policy.json

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonCognitoPowerUser --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRDSFullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonSSMFullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --group-name eks-deployer
aws iam attach-group-policy --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/EKSPolicy" --group-name eks-deployer

aws iam create-user --user-name eks-deployer

aws iam add-user-to-group --user-name eks-deployer --group-name eks-deployer

aws iam create-access-key --user-name eks-deployer
```
