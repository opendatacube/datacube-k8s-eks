resource "aws_iam_role" "eks_node" {
  name = "nodes.${var.cluster_id}"

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  POLICY

  tags = merge(
    {
      Name        = "nodes.${var.cluster_id}"
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_iam_policy" "eks_kube2iam" {
  name        = "${var.cluster_id}-kube2iam"
  path        = "/"
  description = "Enables Kube2iam to assume roles"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "sts:AssumeRole"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  EOF

}

resource "aws_iam_policy" "ecr_pullthrough_cache" {
  count       = (var.enable_ecr_pullthough_cache_permissions ? 1 : 0)
  name        = "${var.cluster_id}-ecr-pull-through-cache"
  path        = "/"
  description = "Enables cluster to use ecr pull-through cache."

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "ecr:BatchImportUpstreamImage",
            "ecr:CreateRepository",
            "ecr:TagResource",
            "ecr:CreatePullThroughCacheRule"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  EOF

}

resource "aws_iam_role_policy_attachment" "eks_node_kube2iam" {
  policy_arn = aws_iam_policy.eks_kube2iam.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_pullthrough" {
  count      = (var.enable_ecr_pullthough_cache_permissions ? 1 : 0)
  policy_arn = aws_iam_policy.ecr_pullthrough_cache[0].arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2RoleforSSM" {
  count      = var.enable_ec2_ssm ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_instance_profile" "eks_node" {
  name = "${var.cluster_id}-node"
  role = aws_iam_role.eks_node.name
}

