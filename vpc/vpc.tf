resource "aws_vpc" "winserver_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "winserver"
  }
}

resource "aws_internet_gateway" "winserver_vpc" {
  vpc_id = aws_vpc.winserver_vpc.id

  tags = {
    Name = "winserver"
  }
}

resource "aws_eip" "winserver_ngw" {
  vpc = true

  tags = {
    Name = "winserver-ngw"
  }
}

resource "aws_nat_gateway" "winserver" {
  allocation_id = aws_eip.winserver_ngw.id
  subnet_id     = format("%s", aws_subnet.public[0].id)

  tags = {
    Name = "winserver"
  }

  depends_on = [aws_eip.winserver_ngw]
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.winserver_vpc.id
  availability_zone       = format("%s", data.aws_availability_zones.available.names[count.index])
  cidr_block              = cidrsubnet(aws_vpc.winserver_vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name" = "winserver-public-${format("%s", data.aws_availability_zones.available.names[count.index])}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.winserver_vpc.id
  availability_zone = format("%s", data.aws_availability_zones.available.names[count.index])
  cidr_block        = cidrsubnet(aws_vpc.winserver_vpc.cidr_block, 8, count.index + 2)

  tags = {
    "Name" = "winserver-private-${format("%s", data.aws_availability_zones.available.names[count.index])}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.winserver_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.winserver_vpc.id
  }

  tags = {
    Name = "winserver-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.winserver_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.winserver.id
  }

  tags = {
    Name = "winserver-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "region-name"
    values = [var.region]
  }
}

