# Cluster Access

## Pre-requisites

You'll need to know how to build the cluster first. This is covered in detail in the [Getting Started Guide](./getting_started.md)

You'll need either:
1. a user account with mfa enabled. See the [AWS guide for setting up MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html)
2. an IAM Role associated with your AWS account that you want to give access to managing the k8s cluster. This scenario
    will also work with AWS SSO accounts since they assume IAM roles

You'll need the [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

For MFA accounts we recommend using [aws-vault](https://github.com/99designs/aws-vault) as it makes assuming roles much easier on the cli.

## Add Users to your cluster

### For a user account with MFA:

edit your `02_odc_k8s/odc_k8s.tf` file, and add your current aws user (if you already have a users section overwrite it with the following)

If you don't know your username you can check by running 

```sh
aws sts get-caller-identity --query 'Arn' --output text
```

It'll output your user: `arn:aws:iam::0123456789012:user/janedoe`

```terraform
users = {
  janedoe: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/janedoe"
}
```

### For an IAM role:
This field also supports roles if you aren't directly using cli users.
You will need the IAM Role ARN that you wish to grant access to the cluster.
It'll look something like `arn:aws:sts::${data.aws_caller_identity.current.account_id}:role/user.<your-cluster-id>-clusteradmin`

Set the role like this: 

```terraform
user_roles = {
  cluster-admin: "arn:aws:sts::${data.aws_caller_identity.current.account_id}:role/user.<your-cluster-id>-clusteradmin"
}
```

Now apply the configuration using -

```sh
cd examples/02_odc_k8s
terraform init
terraform plan
terraform apply
```

The user/role will be allowed to access the cluster, but you'll need to configure your aws config file first to show it how.

## Setup aws config file

You can find your config file at `~/.aws/config` on macOS and Linux, and in `%UserProfile\.aws` on Windows.
See [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for more information.

you'll need to know your account id for the next step, you can find it using the aws cli

```sh
aws sts get-caller-identity --query 'Account' --output text
```

now edit the config file and add the following section:

```config
[profile <your-cluster-id>]
source_profile = default
role_arn = arn:aws:iam::<aws-account>:role/user.<your-cluster-id>-clusteradmin # Needed if using a role based access
mfa_serial = arn:aws:iam::<aws-account>:mfa/<user name> # Needed if  using a user with mfa based access
```
- `profile` defines what you want to call the local profile when calling it using the cli
- `source_profile` defines what user account you want to use to assume this role
- `role_arn` is the aws role we will be using to access the cluster, replace the `<aws-account>` with your account id
- `mfa_serial` is the mfa device associated with the user account (you'll need this if you've enforced mfa on your admin accounts which you should do), replace the `<aws-account>` with your account id, replace `<user name>` with your user name. _If using a role remove this line_

## Assume the role

If you are using [aws-vault](https://github.com/99designs/aws-vault):

```sh
aws-vault exec <your-cluster-id> --
```

You will be prompted for the password you setup when installing aws-vault, and your mfa token.

If you aren't using aws-vault you can set your default profile 

on macOS and Linux:

```sh
export AWS_DEFAULT_PROFILE=<your-cluster-profile>
```

on Windows:

```sh
setx AWS_DEFAULT_PROFILE <your-cluster-profile>
```

If you are using a role you have two options:
1. add `--profile <your-cluster-profile>` to your aws CLI commands e.g. `aws eks describe-cluster --name <your-cluster-id> --profile <your-cluster-profile>`
2. obtain some temporary credentials and add them to your aws `credentials` file using:
`aws sts assume-role --role-arn arn:aws:iam::<aws-account>:role/user.<your-cluster-id>-cluateradmin --role-session-name <your-session-name>`

Note that the aws CLI `--profile` basically does 2 for you behind the scenes but it won't last. You need to use option 2 for doing useful things with `kubectl`.
_Session credentials from 2 are temporary and by default expire in 1 hour. You can change this using additional command line options. see `aws sts assume-role help` for details._

## Get the kubeconfig 

To access the cluster you'll need to load the kubeconfig file, you can do this
using the aws cli:

```sh
aws eks --region ap-southeast-2 update-kubeconfig --name <your cluster id>
```

## Test it out

now that you've got access to the cluster you can interact with it

```sh
kubectl get pods --all-namespaces
```

you should see a list of the pods that are running on your cluster
