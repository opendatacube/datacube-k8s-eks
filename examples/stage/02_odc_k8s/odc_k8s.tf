module "odc_k8s" {
  //    source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s?ref=master"
  source = "../../../odc_k8s"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  region     = local.region
  cluster_id = local.cluster_id

  # Cluster Access Options
  node_roles = {
    "system:node:{{EC2PrivateDNSName}}" = data.terraform_remote_state.odc_eks-stage.outputs.node_role_arn
  }
  # Optional: user_roles and users
  # Example:
  # user_roles = {
  #   cluster-admin: <user-role-arn>
  # }
  users = {
    dominic = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/dev-eks-deployer",
    ngandhi = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/dev-eks-deployer"
  }

  # Database
  store_db_creds    = local.store_db_creds
  # db_hostname       = local.db_hostname
  # db_admin_username = local.db_admin_username
  # db_admin_password = local.db_admin_password

  # Setup Flux/FluxCloud
  flux_enabled             = false
  flux_version             = "1.10.2"
  flux_git_repo_url        = "git@github.com:opendatacube/flux-odc-sample.git"
  flux_git_branch          = "master"
  flux_git_path            = "flux"
  flux_git_label           = local.cluster_id
  flux_service_account_arn = module.role_flux.role_arn
  # Flux helm-operator
  flux_helm_operator_version = "1.4.0"
  enabled_helm_versions      = "v3"
  # Flux FluxCloud
  fluxcloud_enabled         = false
  fluxcloud_slack_url       = ""
  fluxcloud_slack_channel   = ""
  fluxcloud_slack_name      = "Flux Example Deployer"
  fluxcloud_slack_emoji     = ":zoidberg:"
  fluxcloud_github_url      = "https://github.com/opendatacube/flux-odc-sample"
  fluxcloud_commit_template = "{{ .VCSLink }}/commits/{{ .Commit }}"


  # Cloudwatch Log Group - for fluentd
  cloudwatch_logs_enabled  = true
  cloudwatch_log_group     = "${local.cluster_id}-logs"
  cloudwatch_log_retention = 90
}
