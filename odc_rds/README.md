# Terraform Open Data Cube EKS Supporting Module: cognito

Terraform ODC supporting module that creates AWS RDS resources on AWS.

#### Warning

* Create a ODC cluster environment using [odc_eks](https://github.com/opendatacube/datacube-k8s-eks/tree/master/odc_eks) first.

---

## Requirements

[AWS CLI](https://aws.amazon.com/cli/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[Helm](https://github.com/kubernetes/helm#install)

[Terraform](https://www.terraform.io/downloads.html)

[Fluxctl](https://docs.fluxcd.io/en/stable/tutorials/get-started.html) - (optional)

## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/master/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```terraform
module "db" {
  source = "github.com/opendatacube/datacube-k8s-eks//odc_rds?ref=master"

  # Label prefix for db resources
  name = "odc-stage-cluster"

  # Networking
  vpc_id                = module.odc_eks.vpc_id
  database_subnet_group = module.odc_eks.database_subnets

  db_name         = "odc"
  rds_is_multi_az = "false"
  # extra_sg could be empty, so we run compact on the list to remove it if it is
  access_security_groups = [module.odc_eks.node_security_group]
  #Engine version
  engine_version = { postgres = "11.5" }

  # Default tags
  owner           = "odc-owner"
  namespace       = "odc"
  environment     = "stage"
    
  # Additional Tags
  tags = {
    "stack_name" = "odc-stage-cluster"
    "cost_code" = "CC1234"
    "project" = "ODC"
  }
}
```

## Variables

### Inputs
| Name                    | Description                                                                                                                                                                             | Type         | Default                         | Required |
| ------                  | -------------                                                                                                                                                                           | :----:       | :-----:                         | :-----:  |
| owner                   | The owner of the environment                                                                                                                                                            | string       |                                 | Yes      |
| namespace               | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc'                                                                             | string       |                                 | Yes      |
| environment             | The name of the environment - e.g. dev, stage                                                                                                                                           | string       |                                 | Yes      |
| name                    | Name to be used on all the db resources as identifier                                                                                                                                   | string       |                                 | Yes      |
| database_subnet_group   | A list of Subnet Group for the database                                                                                                                                                 | list(string) |                                 | Yes      |
| access_security_groups  | A list of Security Group ID's to allow access to                                                                                                                                        | list(string) |                                 | Yes      |
| vpc_id                  | VPC ID for your database                                                                                                                                                                | string       |                                 | Yes      |
| db_name                 | The name of your RDS database                                                                                                                                                           | string       |                                 | Yes      |
| db_admin_username       | Master DB username                                                                                                                                                                      | string       | "superuser"                     | No       |
| db_multi_az             | If set to true your RDS will have read replicas in other Availability Zones, recommended for production environments to ensure the system will tolerate failure of an Availability Zone | bool         | false                           | No       |
| db_port_num             | The port on which to accept connections                                                                                                                                                 | string       | "5432"                          | No       |
| db_storage              | RDS storage size in GB. If this is increased it cannot be decreased                                                                                                                     | string       | "180"                           | No       |
| db_max_storage          | Enables storage autoscaling up to this amount, must be equal to or greater than db_storage, if this value is 0, storage autoscaling is disabled                                         | string       | "0"                             | No       |
| engine                  | Engine type: e.g. mysql, postgres                                                                                                                                                       | string       | "postgres"                      | No       |
| engine_version          | Explicitly sets engine specific version for the database used                                                                                                                           | map          | default = { postgres = "11.5" } | No       |
| instance_class          | Instance type to use                                                                                                                                                                    | string       | "db.m4.xlarge"                  | No       |
| backup_retention_period | How long to keep backups for (in days)                                                                                                                                                  | number       | 30                              | No       |
| backup_window           | When to perform DB maintenance                                                                                                                                                          | string       | "14:00-17:00"                   | No       |
| storage_encrypted       | Specifies whether the underlying storage layer should be encrypted                                                                                                                      | bool         | true                            | No       |
| snapshot_identifier     | Snapshot ID for database creation if a migration is being performed to deploy new infrastructure                                                                                        | string       | ""                              | No       |
| tags                    | Additional tags - e.g. `map('StackName','XYZ')`                                                                                                                                         | map(string)  | {}                              | No       |

### Outputs
| Name              | Description             | Sensitive |
| ------            | -------------           | ------    |
| db_admin_username | Master DB username      | true      |
| db_admin_password | Master DB user password | true      |
| db_hostname       | db hostname             | false     |
| db_port           | db port                 | false     |
