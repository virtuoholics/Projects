


output "tgw1-id" {
  value = aws_ec2_transit_gateway.tgw1.id
}

/*output "tgw1-rtb-id" {
  value = aws_ec2_transit_gateway_route_table.tgw1-rtb.id
}*/

output "tgw1-tgw2-peering-attachment-id" {
  value = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw2.id
}

output "tgw1-tgw3-peering-attachment-id" {
  value = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw3.id
}

/*output "receiver_accept_multi1" {
  value = aws_ram_principal_association.multi1.resource_share_arn
}

output "receiver_accept_tenant1" {
  value = aws_ram_principal_association.tenant1.resource_share_arn
}*/
