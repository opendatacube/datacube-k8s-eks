module "odc_cluster_label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1"
  namespace = local.namespace
  stage     = local.environment
  name      = "eks"
  delimiter = "-"
}

module "odc_eks" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=master"
  source = "../../../odc_eks"

  # Cluster config
  region          = local.region
  cluster_id      = module.odc_cluster_label.id
  cluster_version = local.cluster_version

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  # VPC config
  create_vpc            = "true"
  vpc_cidr              = "10.55.0.0/16"
  public_subnet_cidrs   = ["10.55.0.0/22", "10.55.4.0/22", "10.55.8.0/22"]
  private_subnet_cidrs  = ["10.55.32.0/19", "10.55.64.0/19", "10.55.96.0/19"]
  database_subnet_cidrs = ["10.55.20.0/22", "10.55.24.0/22", "10.55.28.0/22"]

  domain_name = local.domain_name

  # ACM - used by ALB
  create_certificate = local.create_certificate

  # System node instances
  default_worker_instance_type = "t3.medium"
  spot_nodes_enabled           = true
  min_nodes                    = 1
  max_nodes                    = 2
  min_spot_nodes               = 0
  max_spot_nodes               = 2

  # Cloudfront CDN
  # Providing explicit provider for cloudfront distribution certificate - this must be in us-east-1 to work with cloudfront
  providers = {
    aws.us-east-1 = aws.use1
  }

  # Cloudfront CDN
  cf_enable                 = local.cf_enable
  cf_dns_record             = "odc"
  cf_origin_dns_record      = "cached-alb"
  cf_custom_aliases         = []
  cf_certificate_create     = true
  cf_origin_protocol_policy = "https-only"
  cf_log_bucket_create      = true
  cf_log_bucket             = "${local.namespace}-${local.environment}-cloudfront-logs"

  # WAF
  waf_enable            = local.waf_enable
  waf_target_scope      = "regional"
  waf_log_bucket_create = true
  waf_log_bucket        = "${local.namespace}-${local.environment}-waf-logs"
  # Additional setting required to setup URL whitelist string match filter
  # Recommanded if WAF is enabled for `jupyterhub` setup
  waf_enable_url_whitelist_string_match_set = true
  waf_url_whitelist_uri_prefix              = "/user"
  waf_url_whitelist_url_host                = local.sandbox_host_name
}

data "aws_acm_certificate" "domain_cert" {
  depends_on  = [module.odc_eks]
  domain      = "*.${local.domain_name}"
  most_recent = true
}
