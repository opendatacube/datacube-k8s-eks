# Additional Users

## Pre-requisites

You'll need to know how to build the cluster first this is covered in detail in the [Getting Started Guid](./getting_started.md) 

You'll need either:
1. a user account with mfa enabled. See the [AWS guide for setting up MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html)
2. an IAM Role associated with your AWS account that you want to give access to managing the k8s cluster. This scenario will also work with AWS SSO accounts since they assume IAM roles 

You'll need the [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

For MFA accounts we recommend using [aws-vault](https://github.com/99designs/aws-vault) as it makes assuming roles much easier on the cli

## Add Users to your cluster

*For a user account with MFA:*

edit your `terraform.tfvars` file, and add your current aws user (if you already have a users section overwrite it with the following)

If you don't know your username you can check by running 

```bash
aws sts get-caller-identity --query 'Arn' --output text
```

It'll output your user: `arn:aws:iam::0123456789012:user/janedoe`

Copy the last section and put it in the users section of the tfvars file.

```config
users = [
  "user/janedoe",
]
```

*For an IAM role:*
This field also supports roles if you aren't directly using cli users.
You will need the IAM Role ARN that you wish to grant access to the cluster.
It'll look something like `arn:aws:sts::0123456789012:role/YourRoleName/morestuff/possibly_more_stuff/1559711943675672000`

You will use everything after and including the `role/`

Set the role like this: 

```config
users = [
  "role/YourRoleName/morestuff/possibly_more_stuff/1559711943675672000",
]
```

Now apply the configuration using 

```bash
make apply
```

The user/role will be allowed to access the cluster, but you'll need to configure your aws config file first to show it how.

## Setup aws config file

You can find your config file at `~/.aws/config` on macOS and Linux, and in `%UserProfile\.aws` on windows. See [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for more information. 

you'll need to know your account id for the next step, you can find it using the aws cli

```bash
aws sts get-caller-identity --query 'Account' --output text
```

now edit the config file and add the following section:

```config
[profile dev-eks]
source_profile = default
role_arn = arn:aws:iam::123456789012:role/user.dev-eks-datacube
mfa_serial = arn:aws:iam::123456789012:mfa/janedoe # If using a role you remove this line.
```

`profile` defines what you want to call the local profile when calling it using the cli

`source_profile` defines what user account you want to use to assume this role

`role_arn` is the aws role we will be using to access the cluster, replace the `123456789012` with your account id

`mfa_serial` is the mfa device associated with the user account (you'll need this if you've enforced mfa on your admin accounts which you should do), replace the `123456789012` with your account id, replace `janedoe` with your user name. _If using a role remove this line_

## Assume the role

If you are using [aws-vault](https://github.com/99designs/aws-vault):

```bash
aws-vault exec dev-eks --
```

You will be prompted for the password you setup when installing aws-vault, and your mfa token.

If you aren't using aws-vault you can set your default profile 

on macOS and Linux:

```bash
export AWS_DEFAULT_PROFILE=dev-eks
```

on Windows:

```bash
setx AWS_DEFAULT_PROFILE dev-eks
```

If you are using a role you have two options:
1. add `--profile dev-eks` to your aws CLI commands e.g. `aws eks describe-cluster --name dev-eks-datacube --profile dev-eks`
2. obtain some temporary credentials and add them to your aws `credentials` file using:
`aws sts assume-role --role-arn arn:aws:iam::444488357543:role/user.dev-eks-datacube --role-session-name woo409-eks-role-test`

Note that the aws CLI `--profile` basically does 2 for you behind the scenes but it won't last. You need to use option 2 for doing useful things with `kubectl`.
_Session credentials from 2 are temporary and by default expire in 1 hour. You can change this using additional command line options. see `aws sts assume-role help` for details._

## Get the kubeconfig 

To access the cluster you'll need to load the kubeconfig file, you can do this
using the aws cli:

```bash 
aws eks --region ap-southeast-2 update-kubeconfig --name <your cluster name>
```


## Test it out

now that you've got access to the cluster you can interact with it

```bash
kubectl get pods --all-namespaces
```

you should see a list of the pods that are running on your cluster
