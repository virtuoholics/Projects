resource "aws_vpc" "tenant3-vpc1" {
  cidr_block           = "10.8.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tenant3-vpc1"
  }
}

resource "aws_subnet" "tenant3-vpc1-nlb-subnet" {
  vpc_id            = aws_vpc.tenant3-vpc1.id
  availability_zone = "us-east-2a"
  cidr_block        = "10.8.0.0/25"

  tags = {
    Name = "tenant3-vpc1-nlb-subnet"
  }
}

resource "aws_subnet" "tenant3-vpc1-tgw-subnet" {
  vpc_id                  = aws_vpc.tenant3-vpc1.id
  availability_zone       = "us-east-2a"
  cidr_block              = "10.8.0.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "tenant3-vpc1-tgw-subnet"
  }
}

resource "aws_route_table" "tenant3-vpc1-nlb-subnet" {
  vpc_id = aws_vpc.tenant3-vpc1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw3
  }

  tags = {
    Name = "tenant3-vpc1-nlb-subnet"
  }
}

resource "aws_route_table_association" "tenant3-vpc1-nlb-subnet" {
  subnet_id      = aws_subnet.tenant3-vpc1-nlb-subnet.id
  route_table_id = aws_route_table.tenant3-vpc1-nlb-subnet.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tenant3-vpc1" {
  subnet_ids         = [aws_subnet.tenant3-vpc1-tgw-subnet.id]
  transit_gateway_id = var.tgw3
  vpc_id             = aws_vpc.tenant3-vpc1.id

  #transit_gateway_default_route_table_association = false
  #transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "tenant3-vpc1-creator"
  }
}

/*resource "aws_ram_resource_share_accepter" "receiver_accept" {
  share_arn = var.receiver_accept
}*/

resource "aws_ec2_transit_gateway_route_table_association" "tenant3-vpc1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tenant3-vpc1.id
  transit_gateway_route_table_id = var.tgw3-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tenant3-vpc1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tenant3-vpc1.id
  transit_gateway_route_table_id = var.tgw3-rtb
}

/*data "aws_route_table" "tenant3-vpc1" {
  vpc_id = aws_vpc.tenant3-vpc1.id

  filter {
    name   = "association.main"
    values = ["true"]
  }

  depends_on = [aws_vpc.tenant3-vpc1]
}*/
