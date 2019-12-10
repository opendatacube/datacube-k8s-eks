variable "custom_kube2iam_roles" {
  type        = "list"
  default     = []
  description = "Specify custom IAM roles that can be used by pods on the k8s cluster"
  # custom_kube2iam_roles = [
  #   {
  #       name = "foo"
  #       policy = <<-EOF
  #       IAMPolicyDocument
  #         WithIdents
  #       EOF
  #   }
  # ]
}

resource "aws_iam_role" "custom_role" {
  count              = length(var.custom_kube2iam_roles)
  name               = "${var.cluster_id}-${var.custom_kube2iam_roles[count.index].name}"
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
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_id}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "custom_role_policy" {
  count  = length(var.custom_kube2iam_roles)
  name   = "${var.cluster_id}-${var.custom_kube2iam_roles[count.index].name}"
  role   = aws_iam_role.custom_role[count.index].id
  policy = var.custom_kube2iam_roles[count.index].policy
}