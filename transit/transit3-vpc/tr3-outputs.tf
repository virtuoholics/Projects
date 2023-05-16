

output "transit-vpc3-attachment-id" {
  value = aws_ec2_transit_gateway_vpc_attachment.transit_3.id
}

output "transit-vpc3-alb-dns-name" {
  value = aws_lb.transit_3.dns_name
}

