module "odc_k8s" {
//    source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s?ref=terraform-aws-odc"
  source = "../../../odc_k8s"
  # Cluster config
  region       = local.region
  owner        = local.owner
  cluster_name = local.cluster_name

  # Cluster Access Options
  node_roles = {
    "system:node:{{EC2PrivateDNSName}}": data.terraform_remote_state.odc_eks-stage.outputs.node_role_arn
  }
  # Optional: user_roles and users
  # user_roles = {
  #   cluster-admin: data.terraform_remote_state.odc_eks-stage.outputs.user_role_arn
  # }
  users = {
    eks-deployer: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/dev-eks-deployer"
  }

  # Database
  store_db_creds    = true
  db_hostname       = local.db_hostname
  db_admin_username = local.db_admin_username
  db_admin_password = local.db_admin_password

  # Setup Flux/FluxCloud
  flux_enabled = false
  flux_git_repo_url = "git@github.com:opendatacube/flux-odc-sample.git"
  flux_git_branch = "master"
  flux_git_path = "flux"
  #flux_git_label = "flux-sync"

  fluxcloud_enabled = false
  fluxcloud_slack_url = ""
  fluxcloud_slack_channel = ""
  fluxcloud_slack_name = "Flux Example Deployer"
  fluxcloud_slack_emoji = ":zoidberg:"
  fluxcloud_github_url = "https://github.com/opendatacube/flux-odc-sample"
  fluxcloud_commit_template = "{{ .VCSLink }}/commits/{{ .Commit }}"


  # Cloudwatch Log Group - for fluentd
  cloudwatch_logs_enabled  = true
  cloudwatch_log_group     = "${local.cluster_name}-logs"
  cloudwatch_log_retention = 90
}