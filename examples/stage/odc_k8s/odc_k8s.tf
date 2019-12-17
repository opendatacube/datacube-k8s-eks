data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "aws_caller_identity" "current" {
}

module "odc_k8s" {
//    source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s?ref=terraform-aws-odc"
  source = "../../../odc_k8s"
  # Cluster config
  region = data.terraform_remote_state.odc_eks-stage.outputs.region

  owner = data.terraform_remote_state.odc_eks-stage.outputs.owner
  cluster_name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id

  users = {
    "eks-deployer": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/dev-eks-deployer"
  }

  roles = {
    "node-role": data.terraform_remote_state.odc_eks-stage.outputs.node_role_arn,
    "user-role": data.terraform_remote_state.odc_eks-stage.outputs.user_role_arn
  }

  # Database
  store_db_creds = true
  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_admin_username = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username
  db_admin_password = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username

  # Setup Flux/FluxCloud
  fluxcloud_enabled = false
//  flux_git_repo_url = ""
//  flux_git_branch = ""
//  flux_git_label = ""
  fluxcloud_slack_url = "" # "https://hooks.slack.com/services/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"
  fluxcloud_slack_channel = "" # "#ga-wms-updates"
  fluxcloud_slack_name = "Flux Deployer"
  fluxcloud_slack_emoji = ":zoidberg:"
  fluxcloud_github_url = "https://github.com/opendatacube/flux-odc-sample"
  fluxcloud_commit_template = "{{ .VCSLink }}/commits/{{ .Commit }}"
}