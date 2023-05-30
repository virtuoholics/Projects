resource "aws_vpc" "devsecops_project" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devsecops-project"
  }
}

resource "aws_internet_gateway" "devsecops_project" {
  vpc_id = aws_vpc.devsecops_project.id

  tags = {
    Name = "devsecops-project"
  }
}

resource "aws_eip" "devsecops_project" {
  count = length(local.eip_allocation)
  vpc   = true

  tags = {
    Name = "devsecops-project-${local.eip_allocation[count.index]}"
  }
}

resource "aws_eip_association" "jenkins" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.devsecops_project[2].id
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.devsecops_project[1].id
}

resource "aws_eip_association" "nexus" {
  instance_id   = aws_instance.nexus.id
  allocation_id = aws_eip.devsecops_project[3].id
}

resource "aws_eip_association" "sonarqube" {
  instance_id   = aws_instance.sonarqube.id
  allocation_id = aws_eip.devsecops_project[4].id
}

resource "aws_nat_gateway" "devsecops_project" {
  allocation_id = aws_eip.devsecops_project[0].id
  subnet_id     = aws_subnet.eks_ngw.id

  tags = {
    Name = "devsecops-project"
  }

  depends_on = [aws_internet_gateway.devsecops_project]
}

resource "aws_subnet" "eks_1" {
  vpc_id                  = aws_vpc.devsecops_project.id
  availability_zone       = "${var.region}a"
  cidr_block              = "10.0.128.0/20"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                    = "eks-public-${var.region}a"
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/devsecops-project" = "shared"
  }
}

resource "aws_subnet" "eks_3" {
  vpc_id                  = aws_vpc.devsecops_project.id
  availability_zone       = "${var.region}b"
  cidr_block              = "10.0.144.0/20"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                    = "eks-public-${var.region}b"
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/devsecops-project" = "shared"
  }
}

resource "aws_subnet" "eks_2" {
  vpc_id            = aws_vpc.devsecops_project.id
  availability_zone = "${var.region}a"
  cidr_block        = "10.0.0.0/20"

  tags = {
    "Name"                                    = "eks-private-${var.region}a"
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/devsecops-project" = "shared"
  }
}

resource "aws_subnet" "eks_4" {
  vpc_id            = aws_vpc.devsecops_project.id
  availability_zone = "${var.region}b"
  cidr_block        = "10.0.16.0/20"

  tags = {
    "Name"                                    = "eks-private-${var.region}b"
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/devsecops-project" = "shared"
  }
}

resource "aws_subnet" "eks_ngw" {
  vpc_id                  = aws_vpc.devsecops_project.id
  availability_zone       = "${var.region}a"
  cidr_block              = "10.0.176.0/20"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "eks-ngw-${var.region}a"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devsecops_project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devsecops_project.id
  }

  tags = {
    Name = "eks-public"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.eks_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.eks_3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "ngw" {
  subnet_id      = aws_subnet.eks_ngw.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.devsecops_project.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devsecops_project.id
  }

  tags = {
    Name = "eks-private"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.eks_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.eks_4.id
  route_table_id = aws_route_table.private.id
}

locals {
  eip_allocation = [
    "nat-gw",
    "bastion",
    "jenkins",
    "nexus",
    "sonarqube"
  ]
}


