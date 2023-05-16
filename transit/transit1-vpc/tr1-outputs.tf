


output "transit-vpc1-attachment-id" {
  value = aws_ec2_transit_gateway_vpc_attachment.transit_1.id
}

output "transit-vpc1-alb-dns-name" {
  value = aws_lb.transit_1.dns_name
}

