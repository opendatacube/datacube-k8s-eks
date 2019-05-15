# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "${var.cluster_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.eks.id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_subnet" "eks" {
  count = 3

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index * 8}.0/21"
  vpc_id            = "${aws_vpc.eks.id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
     "kubernetes.io/role/alb-ingress", "",
     "kubernetes.io/role/elb","",
    )
  }"
}

resource "aws_subnet" "db" {
  count = 3

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.20${count.index}.0/24"
  vpc_id            = "${aws_vpc.eks.id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}-db"
    )
  }"
}

resource "aws_internet_gateway" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  tags = {
    Name = "${var.cluster_name}"
  }
}

resource "aws_route_table" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks.id}"
  }
}

resource "aws_route_table_association" "eks" {
  count = 3

  subnet_id      = "${element(aws_subnet.eks.*.id, count.index)}"
  route_table_id = "${aws_route_table.eks.id}"
  depends_on     = ["aws_subnet.eks"]
}
