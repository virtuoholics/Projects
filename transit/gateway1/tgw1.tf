resource "aws_ec2_transit_gateway" "tgw1" {

  #default_route_table_association = "disable"
  #default_route_table_propagation = "disable"
  auto_accept_shared_attachments = "disable" #default

  tags = {
    Name = "tgw-us-west-2"
  }
}

##### ENABLING RESOURCE SHARE FOR MULTI-ACCOUNT SETUP #####

resource "aws_ram_resource_share" "rs-tgw1" {
  name                      = "rs-us-west-2"
  allow_external_principals = true

  tags = {
    Name = "rs-us-west-2"
  }
}

# Sharing transit gateway...
resource "aws_ram_resource_association" "rs-tgw1" {
  resource_arn       = aws_ec2_transit_gateway.tgw1.arn
  resource_share_arn = aws_ram_resource_share.rs-tgw1.arn
}

# ...with multi-region account
resource "aws_ram_principal_association" "multi1" {
  principal          = var.cid-multi1
  resource_share_arn = aws_ram_resource_share.rs-tgw1.arn
}

# ...with tenant1
resource "aws_ram_principal_association" "tenant1" {
  principal          = var.cid-tenant1
  resource_share_arn = aws_ram_resource_share.rs-tgw1.arn
}

# Accepting transit-VPC1's VPC attachment.
/*resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "transit-vpc1" {
  transit_gateway_attachment_id = var.transit-vpc1-attachment

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "transit-vpc1-Accepter"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgw1-rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw1.id
}*/

data "aws_ec2_transit_gateway_route_table" "tgw1-default-rtb" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tgw1.id]
  }

  depends_on = [aws_ec2_transit_gateway.tgw1]
}

resource "aws_ec2_transit_gateway_route" "tgw1-default-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.transit-vpc1-attachment
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw1-default-rtb.id

  depends_on = [data.aws_ec2_transit_gateway_route_table.tgw1-default-rtb]
}

/*resource "aws_ec2_transit_gateway_route" "tgw1-tgw2-route" {
  destination_cidr_block         = "10.0.0.0/14"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw2.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw1-default-rtb.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw1-tgw2]
}*/

resource "aws_ec2_transit_gateway_route" "tgw1-tgw3-route" {
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw3.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw1-default-rtb.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw1-tgw3]
}


