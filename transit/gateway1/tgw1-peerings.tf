resource "aws_ec2_transit_gateway_peering_attachment" "tgw1-tgw2" {
  peer_region             = "us-east-1"
  peer_transit_gateway_id = var.tgw2
  transit_gateway_id      = aws_ec2_transit_gateway.tgw1.id

  tags = {
    Name = "tgw1-tgw2-requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw1-tgw3" {
  peer_region             = "us-east-2"
  peer_transit_gateway_id = var.tgw3
  transit_gateway_id      = aws_ec2_transit_gateway.tgw1.id

  tags = {
    Name = "tgw1-tgw3-requestor"
  }
}
