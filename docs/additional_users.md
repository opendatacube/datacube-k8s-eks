# Additional Users

## Pre-requisites

You'll need to know how to build the cluster first this is covered in detail in the [Getting Started Guid](./getting_started.md) 

You'll need a user account with mfa enabled. See the [AWS guide for setting up MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html)

You'll need the [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

We recommend using [aws-vault](https://github.com/99designs/aws-vault) as it makes assuming roles much easier on the cli

## Add Users to your cluster

edit your `terraform.tfvars` file, and add your current aws user (if you already have a users section overwrite it with the following)

If you don't know your username you can check by running 

```bash
aws iam get-user
```

```config
users = [
  "user/yourawsusername",
]
```

for example:

```config
users = [
  "user/janedoe",
]
```

This field also supports roles if you aren't directly using cli users.

Now apply the configuration using 

```bash
make apply
```

The user will be allowed to access the cluster, but you'll need to configure your aws config file first to show it how.

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
mfa_serial = arn:aws:iam::123456789012:mfa/janedoe
```

`profile` defines what you want to call the local profile when calling it using the cli

`source_profile` defines what user account you want to use to assume this role

`role_arn` is the aws role we will be using to access the cluster, replace the `123456789012` with your account id

`mfa_serial` is the mfa device associated with the user account (you'll need this if you've enforced mfa on your admin accounts which you should do), replace the `123456789012` with your account id, replace `janedoe` with your user name

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