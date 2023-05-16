resource "aws_vpc" "transit_3" {
  cidr_block           = "10.80.6.0/23"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "transit-3"
  }
}

resource "aws_internet_gateway" "transit_3" {
  vpc_id = aws_vpc.transit_3.id

  tags = {
    Name = "transit-3"
  }
}

resource "aws_eip" "transit_3" {
  vpc = true

  tags = {
    Name = "transit3-ngw-eip"
  }
}

resource "aws_nat_gateway" "transit_3" {
  allocation_id = aws_eip.transit_3.id
  subnet_id     = aws_subnet.transit3_nat_alb_1.id

  tags = {
    Name = "transit3-ngw"
  }

  depends_on = [aws_eip.transit_3]
}

resource "aws_subnet" "transit3_tgw" {
  vpc_id            = aws_vpc.transit_3.id
  availability_zone = "${var.az}a"
  cidr_block        = "10.80.7.128/25"

  tags = {
    Name = "transit3-tgw"
  }
}

resource "aws_subnet" "transit3_fw" {
  vpc_id                  = aws_vpc.transit_3.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.80.7.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit3-fw"
  }
}

resource "aws_subnet" "transit3_nat_alb_1" {
  vpc_id                  = aws_vpc.transit_3.id
  availability_zone       = "${var.az}a"
  cidr_block              = "10.80.6.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit3-nat-alb-1"
  }

  depends_on = [aws_internet_gateway.transit_3]
}

resource "aws_subnet" "transit3_nat_alb_2" {
  vpc_id                  = aws_vpc.transit_3.id
  availability_zone       = "${var.az}b"
  cidr_block              = "10.80.6.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "transit3-nat-alb-2"
  }

  depends_on = [aws_internet_gateway.transit_3]
}

resource "aws_route_table" "transit3_tgw_subnet" {
  vpc_id = aws_vpc.transit_3.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = element(flatten(aws_networkfirewall_firewall.transit_3.firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }

  tags = {
    Name = "transit3-tgw-subnet"
  }
}

resource "aws_route_table_association" "transit3_tgw_subnet" {
  subnet_id      = aws_subnet.transit3_tgw.id
  route_table_id = aws_route_table.transit3_tgw_subnet.id
}

resource "aws_route_table" "transit3_fw_subnet" {
  vpc_id = aws_vpc.transit_3.id

  route {
    cidr_block         = "10.0.0.0/16"
    transit_gateway_id = var.tgw3
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.transit_3.id
  }

  tags = {
    Name = "transit3-fw-subnet"
  }
}

resource "aws_route_table_association" "transit3_fw_subnet" {
  subnet_id      = aws_subnet.transit3_fw.id
  route_table_id = aws_route_table.transit3_fw_subnet.id
}

resource "aws_route_table" "transit3_nat_alb_subnets" {
  vpc_id = aws_vpc.transit_3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_3.id
  }

  route {
    cidr_block      = "10.0.0.0/16"
    vpc_endpoint_id = element(flatten(aws_networkfirewall_firewall.transit_3.firewall_status[0].sync_states[*].attachment[*].endpoint_id), 0)
  }

  tags = {
    Name = "transit3-nat-alb-subnets"
  }
}

resource "aws_route_table_association" "transit3_nat_alb_subnets1" {
  subnet_id      = aws_subnet.transit3_nat_alb_1.id
  route_table_id = aws_route_table.transit3_nat_alb_subnets.id
}

resource "aws_route_table_association" "transit3_nat_alb_subnets2" {
  subnet_id      = aws_subnet.transit3_nat_alb_2.id
  route_table_id = aws_route_table.transit3_nat_alb_subnets.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_3" {
  subnet_ids         = [aws_subnet.transit3_tgw.id]
  transit_gateway_id = var.tgw3
  vpc_id             = aws_vpc.transit_3.id

  #transit_gateway_default_route_table_association = false
  #transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "transit3-creator"
  }
}

/*resource "aws_ec2_transit_gateway_route_table_association" "transit_3" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_3.id
  transit_gateway_route_table_id = var.tgw3-rtb
}

resource "aws_ec2_transit_gateway_route_table_propagation" "transit_3" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_3.id
  transit_gateway_route_table_id = var.tgw3-rtb
}

data "aws_route_table" "transit_3" {
  vpc_id = aws_vpc.transit_3.id

  filter {
    name   = "association.main"
    values = ["true"]
  }

  depends_on = [aws_vpc.transit_3]
}*/
