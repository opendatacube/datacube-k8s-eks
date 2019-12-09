module "odc_eks" {
    source = "../"

# Cluster config
region = "us-west-2"

owner = "cube-owner"
cluster_name = "datacube-test"
cluster_version = 1.13

admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

users = [
  "role/aws-reserved/sso.amazonaws.com/ap-southeast-2/AWSReservedSSO_PowerUserAccess_e8e0b2fbcf2f8f8e",
]

domain_name = "domain.name"

# Database config
store_db_credentials = true

}