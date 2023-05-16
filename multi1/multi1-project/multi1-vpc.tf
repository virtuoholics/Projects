resource "aws_vpc" "multi1" {
  cidr_block           = "10.4.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "multi1"
  }
}

resource "aws_subnet" "multi1-nlb-subnet" {
  vpc_id            = aws_vpc.multi1.id
  availability_zone = "${var.az}a"
  cidr_block        = "10.4.0.0/25"

  tags = {
    Name = "multi1-nlb-subnet"
  }
}

resource "aws_subnet" "multi1-tgw-subnet" {
  vpc_id                  = aws_vpc.multi1.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.4.0.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "multi1-tgw-subnet"
  }
}

resource "aws_route_table" "multi1-nlb-subnet" {
  vpc_id = aws_vpc.multi1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw1
  }

  tags = {
    Name = "multi1-nlb-subnet"
  }
}

resource "aws_route_table_association" "multi1-nlb-subnet" {
  subnet_id      = aws_subnet.multi1-nlb-subnet.id
  route_table_id = aws_route_table.multi1-nlb-subnet.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "multi1" {
  subnet_ids         = [aws_subnet.multi1-tgw-subnet.id]
  transit_gateway_id = var.tgw1
  vpc_id             = aws_vpc.multi1.id

  #transit_gateway_default_route_table_association = false
  #transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "multi1-creator"
  }
}

/*resource "aws_ram_resource_share_accepter" "receiver_accept" {
  share_arn = var.receiver_accept
}*/

resource "aws_ec2_transit_gateway_route_table_association" "multi1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.multi1.id
  transit_gateway_route_table_id = var.tgw1-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "multi1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.multi1.id
  transit_gateway_route_table_id = var.tgw1-rtb
}

/*data "aws_route_table" "multi1" {
  vpc_id = aws_vpc.multi1.id

  filter {
    name   = "association.main"
    values = ["true"]
  }

  depends_on = [aws_vpc.multi1]
}*/
