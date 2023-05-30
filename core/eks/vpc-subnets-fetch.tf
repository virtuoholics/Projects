data "aws_vpc" "devsecops_eks" {
  filter {
    name = "tag:Name"
    values = [
      "devsecops VPC"
    ]
  }
}

data "aws_subnets" "devsecops_eks" {
  filter {
    name = "tag:Name"
    values = [
      "devsecops-Private*",
      "devsecops-Public*"
    ]
  }
}

data "aws_subnets" "devsecops_eks_private" {
  filter {
    name = "tag:Name"
    values = [
      "devsecops-Private*",
    ]
  }
}

data "aws_subnets" "devsecops_eks_public" {
  filter {
    name = "tag:Name"
    values = [
      "devsecops-Public*",
    ]
  }
}
