provider "aws" {
  alias = "peer"
  region = "${var.peer_region}"
  access_key = "${var.peer_access_key}"
  secret_key = "${var.peer_secret_key}"
}

data "aws_vpc" "peer_vpc" {
  provider = "aws.peer"
  id = "${var.peer_vpc_id}"
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "aws_caller_identity" "owner" {}

data "aws_caller_identity" "peer" {
  provider = "aws.peer"
}

resource "aws_vpc_peering_connection" "owner" {
  count = "${var.enable ? 1 : 0}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  peer_vpc_id = "${data.aws_vpc.peer_vpc.id}"
  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  auto_accept = false

  tags {
    name = "NCI CubeDash Peering ${data.aws_vpc.vpc.id} to ${data.aws_vpc.peer_vpc.id}"
    side = "owner"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  count = "${var.enable ? 1 : 0}"
  provider = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
  auto_accept = true

  tags {
    name = "NCI CubeDash Peering Accepter ${data.aws_vpc.vpc.id} to ${data.aws_vpc.peer_vpc.id}"
    side = "peer"
  }
}

resource "aws_vpc_peering_connection_options" "owner" {
  count = "${var.enable ? 1 : 0}"

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.accepter.id}"

  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  count = "${var.enable ? 1 : 0}"
  provider = "aws.peer"

  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.accepter.id}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

data "aws_route_table" "owner_vpc_route_table" {
  count = "${length(var.owner_subnets_to_route)}"
  subnet_id = "${var.owner_subnets_to_route[count.index]}"
}

resource "aws_route" "owner_vpc_route" {
  count = "${var.enable ? length(var.owner_subnets_to_route) : 0}"
  route_table_id            = "${data.aws_route_table.owner_vpc_route_table.*.id[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.peer_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
}

data "aws_route_tables" "peer_vpc_route_tables" {
  provider = "aws.peer"
  vpc_id = "${data.aws_vpc.peer_vpc.id}"

}

resource "aws_route" "peer_vpc_route" {
  provider = "aws.peer"
  count = "${var.enable ? length(data.aws_route_tables.peer_vpc_route_tables.ids) : 0}"
  route_table_id            = "${data.aws_route_tables.peer_vpc_route_tables.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
}

data "aws_security_groups" "peer_security_groups" {
  provider = "aws.peer"

  filter {
    name   = "group-name"
    values = ["${var.peer_security_group_name_filter}"]
  }
}

data "aws_security_groups" "owner_security_groups" {
  filter {
    name   = "group-name"
    values = ["${var.owner_security_group_name_filter}"]
  }
}

resource "aws_security_group_rule" "allow_owner_to_peer" {
  depends_on = ["aws_route.peer_vpc_route"]
  provider = "aws.peer"
  count = "${var.enable ? length(data.aws_security_groups.peer_security_groups.ids) : 0}"
  type            = "ingress"
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"

  security_group_id = "${data.aws_security_groups.peer_security_groups.ids[count.index]}"
  source_security_group_id = "${data.aws_caller_identity.owner.account_id}/${data.aws_security_groups.owner_security_groups.ids[count.index]}"
}
