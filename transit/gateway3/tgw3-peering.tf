resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw1" {
  transit_gateway_attachment_id = var.tgw1-peering-accepter

  tags = {
    Name = "tgw1-Accepter"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw2" {
  transit_gateway_attachment_id = var.tgw2-peering-accepter

  tags = {
    Name = "tgw2-Accepter"
  }
}
