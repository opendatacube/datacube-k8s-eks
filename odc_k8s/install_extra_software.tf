# null_resource.install_kubectl is a workaround for limitations in the official provider.kubernetes
# This will install kubectl and awscli and initialise it for use with the deployed cluster
# kubectl can then be used via local-exec commands to update k8s configuration for those cases where the
# official provider.kubernetes is not sufficient (e.g. CRD configuration)
# It's the provisioner you want to have, but can't (yet)
# 
# Implementation Notes:
#   + It is essential any resource that use kubectl be added to the triggers block or kubectl will not be installed on any updates
#   + resources using kubectl need to include provisioner blocks for plan and destroy so they clean up after themselves and apply updates
#
# Reference: https://github.com/cloudposse/terraform-aws-eks-cluster/blob/master/auth.tf
variable "install_aws_cli" {
  type        = bool
  default     = false
  description = "Set to `true` to install AWS CLI if the module is provisioned on workstations where AWS CLI is not installed by default, e.g. Terraform Cloud workers"
}

variable "install_kubectl" {
  type        = bool
  default     = false
  description = "Set to `true` to install `kubectl` if the module is provisioned on workstations where `kubectl` is not installed by default, e.g. Terraform Cloud workers"
}

variable "kubectl_version" {
  type        = string
  default     = ""
  description = "`kubectl` version to install. If not specified, the latest version will be used"
}

variable "external_packages_install_path" {
  type        = string
  default     = ""
  description = "Path to install external packages, e.g. AWS CLI and `kubectl`. Used when the module is provisioned on workstations where the external packages are not installed by default, e.g. Terraform Cloud workers"
}

variable "aws_eks_update_kubeconfig_additional_arguments" {
  type        = string
  default     = ""
  description = "Additional arguments for `aws eks update-kubeconfig` command, e.g. `--role-arn xxxxxxxxx`. For more info, see https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html"
}

variable "local_exec_interpreter" {
  type        = string
  default     = "/bin/bash"
  description = "shell to use for local exec"
}

variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
  description = "The path to `kubeconfig` file"
}

locals {
  external_packages_install_path = var.external_packages_install_path == "" ? join("/", [abspath(path.module), ".terraform/bin"]) : var.external_packages_install_path
  kubectl_version                = var.kubectl_version == "" ? "$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)" : var.kubectl_version

  cluster_name = data.aws_eks_cluster.cluster.id
  interpreter = [var.local_exec_interpreter, "-c"]
  install_kubectl = <<EOT
      set -e
      install_aws_cli=${var.install_aws_cli}
      if [[ "$install_aws_cli" = true ]] ; then
        if [ ! -f ${local.external_packages_install_path}/aws_cli_installed ]
            echo 'Installing AWS CLI...'
            mkdir -p ${local.external_packages_install_path}
            cd ${local.external_packages_install_path}
            curl -LO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
            unzip ./awscli-bundle.zip
            ./awscli-bundle/install -i ${local.external_packages_install_path}
            export PATH=$PATH:${local.external_packages_install_path}:${local.external_packages_install_path}/bin
            echo 'Installed AWS CLI'
            which aws
            aws --version
            touch ${local.external_packages_install_path}/aws_cli_installed
        fi
      fi
      install_kubectl=${var.install_kubectl}
      if [[ "$install_kubectl" = true ]] ; then
        if [ ! -f ${local.external_packages_install_path}/kubectl_installed ]
            echo 'Installing kubectl...'
            mkdir -p ${local.external_packages_install_path}
            cd ${local.external_packages_install_path}
            curl -LO https://storage.googleapis.com/kubernetes-release/release/${local.kubectl_version}/bin/linux/amd64/kubectl
            chmod +x ./kubectl
            export PATH=$PATH:${local.external_packages_install_path}
            echo 'Installed kubectl'
            which kubectl
            touch ${local.external_packages_install_path}/kubectl_installed
        fi
      fi
      if [ ! -f ${local.external_packages_install_path}/kubeconfig_updated]
        echo 'Updating kubeconfig...'
        aws eks update-kubeconfig --name=${local.cluster_name} --region=${var.region} --kubeconfig=${var.kubeconfig_path} ${var.aws_eks_update_kubeconfig_additional_arguments}
        kubectl version --kubeconfig ${var.kubeconfig_path}
        echo 'kubeconfig updated'
        touch ${local.external_packages_install_path}/kubeconfig_updated
      fi
    EOT

 }

# resource "null_resource" "install_kubectl" {

#   triggers = {
#     cluster_updated                     = data.aws_eks_cluster.cluster.id
#     fluxcrd_updated                     = "${join(",",null_resource.apply_flux_crd.*.id)}"
#     # configmap_auth_file_content_changed = join("", local_file.configmap_auth.*.content)
#   }

#   depends_on = [data.aws_eks_cluster.cluster]

#   provisioner "local-exec" {
#     interpreter = [var.local_exec_interpreter, "-c"]

#   }
# }