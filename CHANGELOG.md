# v1.10.0 odc_eks - Optional vpc creation update procedure

Making VPC creation optional has added a `count` to the `module.odc_eks.module.vpc` resource path.
Use `terraform state mv` to move existing`module.odc_eks.module.vpc` resources to `module.odc_eks.module.vpc[0]`. Suitable commands are below.

Result:
  * Terraform Apply will show no change in infrastructure for default configuration of `vpc_create = true`
  * Outputs may be reported as updated (`database_subnet`) but the values will be identical and there will be no upstream impacts.

```
terraform state mv module.odc_eks.module.vpc module.odc_eks.module.vpc[0]
terraform state mv module.odc_eks.module.vpc.data.aws_vpc_endpoint_service.s3[0] module.odc_eks.module.vpc[0].data.aws_vpc_endpoint_service.s3[0]
terraform state mv module.odc_eks.module.vpc.aws_db_subnet_group.database[0] module.odc_eks.module.vpc[0].aws_db_subnet_group.database[0]
terraform state mv module.odc_eks.module.vpc.aws_eip.nat[0] module.odc_eks.module.vpc[0].aws_eip.nat[0]
terraform state mv module.odc_eks.module.vpc.aws_eip.nat[1] module.odc_eks.module.vpc[0].aws_eip.nat[1]
terraform state mv module.odc_eks.module.vpc.aws_eip.nat[2] module.odc_eks.module.vpc[0].aws_eip.nat[2]
terraform state mv module.odc_eks.module.vpc.aws_internet_gateway.this[0] module.odc_eks.module.vpc[0].aws_internet_gateway.this[0]
terraform state mv module.odc_eks.module.vpc.aws_nat_gateway.this[0] module.odc_eks.module.vpc[0].aws_nat_gateway.this[0]
terraform state mv module.odc_eks.module.vpc.aws_nat_gateway.this[1] module.odc_eks.module.vpc[0].aws_nat_gateway.this[1]
terraform state mv module.odc_eks.module.vpc.aws_nat_gateway.this[2] module.odc_eks.module.vpc[0].aws_nat_gateway.this[2]
terraform state mv module.odc_eks.module.vpc.aws_route.private_nat_gateway[0] module.odc_eks.module.vpc[0].aws_route.private_nat_gateway[0]
terraform state mv module.odc_eks.module.vpc.aws_route.private_nat_gateway[1] module.odc_eks.module.vpc[0].aws_route.private_nat_gateway[1]
terraform state mv module.odc_eks.module.vpc.aws_route.private_nat_gateway[2] module.odc_eks.module.vpc[0].aws_route.private_nat_gateway[2]
terraform state mv module.odc_eks.module.vpc.aws_route.public_internet_gateway[0] module.odc_eks.module.vpc[0].aws_route.public_internet_gateway[0]
terraform state mv module.odc_eks.module.vpc.aws_route_table.private[0] module.odc_eks.module.vpc[0].aws_route_table.private[0]
terraform state mv module.odc_eks.module.vpc.aws_route_table.private[1] module.odc_eks.module.vpc[0].aws_route_table.private[1]
terraform state mv module.odc_eks.module.vpc.aws_route_table.private[2] module.odc_eks.module.vpc[0].aws_route_table.private[2]
terraform state mv module.odc_eks.module.vpc.aws_route_table.public[0] module.odc_eks.module.vpc[0].aws_route_table.public[0]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.database[0] module.odc_eks.module.vpc[0].aws_route_table_association.database[0]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.database[1] module.odc_eks.module.vpc[0].aws_route_table_association.database[1]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.database[2] module.odc_eks.module.vpc[0].aws_route_table_association.database[2]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.private[0] module.odc_eks.module.vpc[0].aws_route_table_association.private[0]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.private[1] module.odc_eks.module.vpc[0].aws_route_table_association.private[1]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.private[2] module.odc_eks.module.vpc[0].aws_route_table_association.private[2]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.public[0] module.odc_eks.module.vpc[0].aws_route_table_association.public[0]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.public[1] module.odc_eks.module.vpc[0].aws_route_table_association.public[1]
terraform state mv module.odc_eks.module.vpc.aws_route_table_association.public[2] module.odc_eks.module.vpc[0].aws_route_table_association.public[2]
terraform state mv module.odc_eks.module.vpc.aws_subnet.database[0] module.odc_eks.module.vpc[0].aws_subnet.database[0]
terraform state mv module.odc_eks.module.vpc.aws_subnet.database[1] module.odc_eks.module.vpc[0].aws_subnet.database[1]
terraform state mv module.odc_eks.module.vpc.aws_subnet.database[2] module.odc_eks.module.vpc[0].aws_subnet.database[2]
terraform state mv module.odc_eks.module.vpc.aws_subnet.private[0] module.odc_eks.module.vpc[0].aws_subnet.private[0]
terraform state mv module.odc_eks.module.vpc.aws_subnet.private[1] module.odc_eks.module.vpc[0].aws_subnet.private[1]
terraform state mv module.odc_eks.module.vpc.aws_subnet.private[2] module.odc_eks.module.vpc[0].aws_subnet.private[2]
terraform state mv module.odc_eks.module.vpc.aws_subnet.public[0] module.odc_eks.module.vpc[0].aws_subnet.public[0]
terraform state mv module.odc_eks.module.vpc.aws_subnet.public[1] module.odc_eks.module.vpc[0].aws_subnet.public[1]
terraform state mv module.odc_eks.module.vpc.aws_subnet.public[2] module.odc_eks.module.vpc[0].aws_subnet.public[2]
terraform state mv module.odc_eks.module.vpc.aws_vpc.this[0] module.odc_eks.module.vpc[0].aws_vpc.this[0]
terraform state mv module.odc_eks.module.vpc.aws_vpc_endpoint.s3[0] module.odc_eks.module.vpc[0].aws_vpc_endpoint.s3[0]
terraform state mv module.odc_eks.module.vpc.aws_vpc_endpoint_route_table_association.private_s3[0] module.odc_eks.module.vpc[0].aws_vpc_endpoint_route_table_association.private_s3[0]
terraform state mv module.odc_eks.module.vpc.aws_vpc_endpoint_route_table_association.private_s3[1] module.odc_eks.module.vpc[0].aws_vpc_endpoint_route_table_association.private_s3[1]
terraform state mv module.odc_eks.module.vpc.aws_vpc_endpoint_route_table_association.private_s3[2] module.odc_eks.module.vpc[0].aws_vpc_endpoint_route_table_association.private_s3[2]
terraform state mv module.odc_eks.module.vpc.aws_vpc_endpoint_route_table_association.public_s3[0] module.odc_eks.module.vpc[0].aws_vpc_endpoint_route_table_association.public_s3[0]
```