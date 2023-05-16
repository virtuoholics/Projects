output "region" {
  value = data.aws_availability_zones.available.id
}

output "vpc_id" {
  value = aws_vpc.winserver_vpc.id
}

output "single_public_subnet" {
  value = format("%s", aws_subnet.public[0].id)
}

output "single_private_subnet" {
  value = format("%s", aws_subnet.private[0].id)
}

output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "vpc_cidr_block" {
  value = aws_vpc.winserver_vpc.cidr_block
}

/*output "nat_gateway" {
  value = [aws_nat_gateway.winserver]
}*/



