


output "tgw2-id" {
  value = aws_ec2_transit_gateway.tgw2.id
}

/*output "tgw2-rtb-id" {
  value = aws_ec2_transit_gateway_route_table.tgw2-rtb.id
}*/

output "tgw2-tgw3-peering-attachment-id" {
  value = aws_ec2_transit_gateway_peering_attachment.tgw2-tgw3.id
}

/*output "receiver_accept_multi2" {
  value = aws_ram_principal_association.multi2.resource_share_arn
}

output "receiver_accept_tenant2-1" {
  value = aws_ram_principal_association.tenant2-1.resource_share_arn
}

output "receiver_accept_tenant2-2" {
  value = aws_ram_principal_association.tenant2-2.resource_share_arn
}*/
