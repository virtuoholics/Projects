resource "aws_vpc" "tenant3-vpc2" {
  cidr_block           = "10.9.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tenant3-vpc2"
  }
}

resource "aws_subnet" "tenant3-vpc2-ec2-subnet" {
  vpc_id            = aws_vpc.tenant3-vpc2.id
  availability_zone = "us-east-2b"
  cidr_block        = "10.9.0.0/25"

  tags = {
    Name = "tenant3-vpc2-ec2-subnet"
  }
}

resource "aws_subnet" "tenant3-vpc2-tgw-subnet" {
  vpc_id                  = aws_vpc.tenant3-vpc2.id
  availability_zone       = "us-east-2b"
  cidr_block              = "10.9.0.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "tenant3-vpc2-tgw-subnet"
  }
}

resource "aws_route_table" "tenant3-vpc2-ec2-subnet" {
  vpc_id = aws_vpc.tenant3-vpc2.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw3
  }

  tags = {
    Name = "tenant3-vpc2-ec2-subnet"
  }
}

resource "aws_route_table_association" "tenant3-vpc2-ec2-subnet" {
  subnet_id      = aws_subnet.tenant3-vpc2-ec2-subnet.id
  route_table_id = aws_route_table.tenant3-vpc2-ec2-subnet.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tenant3-vpc2" {
  subnet_ids         = [aws_subnet.tenant3-vpc2-tgw-subnet.id]
  transit_gateway_id = var.tgw3
  vpc_id             = aws_vpc.tenant3-vpc2.id

  #transit_gateway_default_route_table_association = false
  #transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "tenant3-vpc2-creator"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tenant3-vpc2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tenant3-vpc2.id
  transit_gateway_route_table_id = var.tgw3-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tenant3-vpc2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tenant3-vpc2.id
  transit_gateway_route_table_id = var.tgw3-rtb
}

/*data "aws_route_table" "tenant3-vpc2" {
  vpc_id = aws_vpc.tenant3-vpc2.id

  filter {
    name   = "association.main"
    values = ["true"]
  }

  depends_on = [aws_vpc.tenant3-vpc2]
}*/
