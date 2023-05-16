resource "aws_vpc" "transit_1" {
  cidr_block           = "10.80.8.0/23"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "transit-1"
  }
}

resource "aws_internet_gateway" "transit_1" {
  vpc_id = aws_vpc.transit_1.id

  tags = {
    Name = "transit-1"
  }
}

resource "aws_eip" "transit_1" {
  vpc = true

  tags = {
    Name = "transit1-ngw-eip"
  }
}

resource "aws_nat_gateway" "transit_1" {
  allocation_id = aws_eip.transit_1.id
  subnet_id     = aws_subnet.transit1_nat_alb_1.id

  tags = {
    Name = "transit1-ngw"
  }

  depends_on = [aws_eip.transit_1]
}

resource "aws_subnet" "transit1_tgw" {
  vpc_id            = aws_vpc.transit_1.id
  availability_zone = "${var.az}a"
  cidr_block        = "10.80.9.128/25"

  tags = {
    Name = "transit1-tgw"
  }
}

resource "aws_subnet" "transit1_fw" {
  vpc_id                  = aws_vpc.transit_1.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.80.9.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit1-fw"
  }
}

resource "aws_subnet" "transit1_nat_alb_1" {
  vpc_id                  = aws_vpc.transit_1.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.80.8.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit1-nat-alb-1"
  }

  depends_on = [aws_internet_gateway.transit_1]
}

resource "aws_subnet" "transit1_nat_alb_2" {
  vpc_id                  = aws_vpc.transit_1.id
  availability_zone       = "${var.az}b"
  cidr_block              = "10.80.8.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit1-nat-alb-2"
  }

  depends_on = [aws_internet_gateway.transit_1]
}

resource "aws_route_table" "transit1_tgw_subnet" {
  vpc_id = aws_vpc.transit_1.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = element(flatten(aws_networkfirewall_firewall.transit_1.firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }

  tags = {
    Name = "transit1-tgw-subnet"
  }
}

resource "aws_route_table_association" "transit1_tgw_subnet" {
  subnet_id      = aws_subnet.transit1_tgw.id
  route_table_id = aws_route_table.transit1_tgw_subnet.id
}

resource "aws_route_table" "transit1_fw_subnet" {
  vpc_id = aws_vpc.transit_1.id

  route {
    cidr_block         = "10.4.0.0/14"
    transit_gateway_id = var.tgw1
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.transit_1.id
  }

  tags = {
    Name = "transit1-fw-subnet"
  }
}

resource "aws_route_table_association" "transit1_fw_subnet" {
  subnet_id      = aws_subnet.transit1_fw.id
  route_table_id = aws_route_table.transit1_fw_subnet.id
}

resource "aws_route_table" "transit1_nat_alb_subnets" {
  vpc_id = aws_vpc.transit_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_1.id
  }

  route {
    cidr_block      = "10.4.0.0/14"
    vpc_endpoint_id = element(flatten(aws_networkfirewall_firewall.transit_1.firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }

  tags = {
    Name = "transit1-nat-alb-subnets"
  }
}

resource "aws_route_table_association" "transit1_nat_alb_subnets1" {
  subnet_id      = aws_subnet.transit1_nat_alb_1.id
  route_table_id = aws_route_table.transit1_nat_alb_subnets.id
}

resource "aws_route_table_association" "transit1_nat_alb_subnets2" {
  subnet_id      = aws_subnet.transit1_nat_alb_2.id
  route_table_id = aws_route_table.transit1_nat_alb_subnets.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_1" {
  subnet_ids         = [aws_subnet.transit1_tgw.id]
  transit_gateway_id = var.tgw1
  vpc_id             = aws_vpc.transit_1.id

  #transit_gateway_default_route_table_association = false
  #transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "transit1-creator"
  }
}

/*resource "aws_ec2_transit_gateway_route_table_association" "transit_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_1.id
  transit_gateway_route_table_id = var.tgw1-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "transit_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_1.id
  transit_gateway_route_table_id = var.tgw1-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "transit_1_default" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_1.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_1.id
}

data "aws_ec2_transit_gateway_route_table" "transit_1" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
}*/
