resource "aws_vpc" "transit_2" {
  cidr_block           = "10.80.4.0/23"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "transit-2"
  }
}

resource "aws_internet_gateway" "transit_2" {
  vpc_id = aws_vpc.transit_2.id

  tags = {
    Name = "transit-2"
  }
}

resource "aws_eip" "transit_2" {
  vpc = true

  tags = {
    Name = "transit2-ngw-eip"
  }
}

resource "aws_nat_gateway" "transit_2" {
  allocation_id = aws_eip.transit_2.id
  subnet_id     = aws_subnet.transit2_nat_alb_1.id

  tags = {
    Name = "transit2-ngw"
  }

  depends_on = [aws_eip.transit_2]
}

resource "aws_subnet" "transit2_tgw" {
  vpc_id            = aws_vpc.transit_2.id
  availability_zone = "${var.az}a"
  cidr_block        = "10.80.5.128/25"

  tags = {
    Name = "transit2-tgw"
  }
}

resource "aws_subnet" "transit2_fw" {
  vpc_id                  = aws_vpc.transit_2.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.80.5.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit2-fw"
  }
}

resource "aws_subnet" "transit2_nat_alb_1" {
  vpc_id                  = aws_vpc.transit_2.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.80.4.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit2-nat-alb-1"
  }

  depends_on = [aws_internet_gateway.transit_2]
}

resource "aws_subnet" "transit2_nat_alb_2" {
  vpc_id                  = aws_vpc.transit_2.id
  availability_zone       = "${var.az}b"
  cidr_block              = "10.80.4.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit2-nat-alb-2"
  }

  depends_on = [aws_internet_gateway.transit_2]
}

resource "aws_route_table" "transit2_tgw_subnet" {
  vpc_id = aws_vpc.transit_2.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = element(flatten(aws_networkfirewall_firewall.transit_2.firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }

  tags = {
    Name = "transit2-tgw-subnet"
  }
}

resource "aws_route_table_association" "transit2_tgw_subnet" {
  subnet_id      = aws_subnet.transit2_tgw.id
  route_table_id = aws_route_table.transit2_tgw_subnet.id
}

resource "aws_route_table" "transit2_fw_subnet" {
  vpc_id = aws_vpc.transit_2.id

  route {
    cidr_block         = "10.0.0.0/14"
    transit_gateway_id = var.tgw2
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.transit_2.id
  }

  tags = {
    Name = "transit2-fw-subnet"
  }
}

resource "aws_route_table_association" "transit2_fw_subnet" {
  subnet_id      = aws_subnet.transit2_fw.id
  route_table_id = aws_route_table.transit2_fw_subnet.id
}

resource "aws_route_table" "transit2_nat_alb_subnets" {
  vpc_id = aws_vpc.transit_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_2.id
  }

  route {
    cidr_block      = "10.0.0.0/14"
    vpc_endpoint_id = element(flatten(aws_networkfirewall_firewall.transit_2.firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }

  tags = {
    Name = "transit2-nat-alb-subnets"
  }
}

resource "aws_route_table_association" "transit2_nat_alb_subnets1" {
  subnet_id      = aws_subnet.transit2_nat_alb_1.id
  route_table_id = aws_route_table.transit2_nat_alb_subnets.id
}

resource "aws_route_table_association" "transit2_nat_alb_subnets2" {
  subnet_id      = aws_subnet.transit2_nat_alb_2.id
  route_table_id = aws_route_table.transit2_nat_alb_subnets.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_2" {
  subnet_ids         = [aws_subnet.transit2_tgw.id]
  transit_gateway_id = var.tgw2
  vpc_id             = aws_vpc.transit_2.id

  #transit_gateway_default_route_table_association = false
  #transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "transit2-creator"
  }
}

/*resource "aws_ec2_transit_gateway_route_table_association" "transit_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_2.id
  transit_gateway_route_table_id = var.tgw2-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "transit_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_2.id
  transit_gateway_route_table_id = var.tgw2-rtb
}

data "aws_route_table" "transit_2" {
  vpc_id = aws_vpc.transit_2.id

  filter {
    name   = "association.main"
    values = ["true"]
  }

  depends_on = [aws_vpc.transit_2]
}*/
