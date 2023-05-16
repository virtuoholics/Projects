resource "aws_ec2_transit_gateway_peering_attachment" "tgw2-tgw3" {
  peer_region             = "us-east-2"
  peer_transit_gateway_id = var.tgw3
  transit_gateway_id      = aws_ec2_transit_gateway.tgw2.id

  tags = {
    Name = "tgw2-tgw3-requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw1" {
  transit_gateway_attachment_id = var.tgw1-peering-accepter

  tags = {
    Name = "tgw1-accepter"
  }
}
