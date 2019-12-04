module "odc_eks" {
    source = "../"

# Cluster config
region = "us-west-2"

owner = "calcube-woo409"
cluster_name = "calcube-woo409"
cluster_version = 1.13

admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

users = [
  "role/aws-reserved/sso.amazonaws.com/ap-southeast-2/AWSReservedSSO_PowerUserAccess_e8e0b2fbcf2f8f8e",
]

domain_name = "woo409.calcube.solutions"

# Database config
db_instance_enabled = true
store_db_credentials = true

}