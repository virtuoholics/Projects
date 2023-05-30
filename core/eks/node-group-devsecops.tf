resource "aws_eks_node_group" "devsecops_eks" {
  cluster_name    = aws_eks_cluster.devsecops_eks.name
  node_group_name = "devsecops-project"
  node_role_arn   = aws_iam_role.node_groups.arn

  subnet_ids     = data.aws_subnets.devsecops_eks_private.ids
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.xlarge"]

  remote_access {
    ec2_ssh_key               = "eks-nodegroup"
    source_security_group_ids = [aws_security_group.node_mgmt.id]
  }

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.worker_nodes,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.container_registry_read_only,
  ]

  tags = {
    Name = "devsecops-project"
  }
}
