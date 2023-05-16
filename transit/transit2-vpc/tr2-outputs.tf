



output "transit-vpc2-attachment-id" {
  value = aws_ec2_transit_gateway_vpc_attachment.transit_2.id
}

output "transit-vpc2-alb-dns-name" {
  value = aws_lb.transit_2.dns_name
}

