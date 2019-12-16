data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }

}

module "odc_k8s" {
//    source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s?ref=terraform-aws-odc"
  source = "../../../odc_k8s"
  # Cluster config
  region = data.terraform_remote_state.odc_eks-stage.outputs.region

  owner = data.terraform_remote_state.odc_eks-stage.outputs.owner
  cluster_name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id

  user_role_arn = data.terraform_remote_state.odc_eks-stage.outputs.user_role_arn
  node_role_arn = data.terraform_remote_state.odc_eks-stage.outputs.node_role_arn

  # Database
  store_db_creds = true
  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_admin_username = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username
  db_admin_password = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username
}