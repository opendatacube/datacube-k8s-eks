# ======================================
# Autoscaler

variable "cluster_autoscaler_enabled" {
  default = false
}

resource "kubernetes_namespace" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler"

    labels {
        managed-by = "Terraform"
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "fluentd-cloudwatch"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "cluster-autoscaler"
  namespace  = "cluster-autoscaler"

  values = [
    "${file("${path.module}/config/autoscaler.yaml")}",
  ]


  set {
    name = "podAnnotations.iam\\.amazonaws\\.com/role"
    value = "${var.cluster_name}-autoscaler"
  }

  set {
    name = "autoDiscovery.clusterName"
    value = "${var.cluster_name}"
  }

  set {
    name = "awsRegion"
    value = "${data.aws_region.current.name}"
  }

  # Uses kube2iam for credentials
  depends_on = ["helm_release.kube2iam", "aws_iam_role.autoscaler", "aws_iam_role_policy.autoscaler", "kubernetes_namespace.cluster-autoscaler"]
}


resource "aws_iam_role" "autoscaler" {
  count = "${var.cluster_autoscaler_enabled}"
  name  = "${var.cluster_name}-autoscaler"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_name}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "autoscaler" {
  count = "${var.cluster_autoscaler_enabled}"
  name  = "${var.cluster_name}-autoscaler"
  role  = "${aws_iam_role.autoscaler.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
