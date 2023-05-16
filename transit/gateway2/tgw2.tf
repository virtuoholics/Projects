resource "aws_ec2_transit_gateway" "tgw2" {

  #default_route_table_association = "disable"
  #default_route_table_propagation = "disable"
  auto_accept_shared_attachments = "disable" #default

  tags = {
    Name = "tgw-us-east-1"
  }
}

##### ENABLING RESOURCE SHARE FOR MULTI-ACCOUNT SETUP #####

resource "aws_ram_resource_share" "rs-tgw2" {
  name                      = "rs-us-east-1"
  allow_external_principals = true

  tags = {
    Name = "rs-us-east-1"
  }
}

# Sharing transit gateway...
resource "aws_ram_resource_association" "rs-tgw2" {
  resource_arn       = aws_ec2_transit_gateway.tgw2.arn
  resource_share_arn = aws_ram_resource_share.rs-tgw2.arn
}

# ...with multi-region account
resource "aws_ram_principal_association" "multi2" {
  principal          = var.cid-multi2
  resource_share_arn = aws_ram_resource_share.rs-tgw2.arn
}

# ...with tenant2-1
resource "aws_ram_principal_association" "tenant2-1" {
  principal          = var.cid-tenant2-1
  resource_share_arn = aws_ram_resource_share.rs-tgw2.arn
}

# ...with tenant2-2
resource "aws_ram_principal_association" "tenant2-2" {
  principal          = var.cid-tenant2-2
  resource_share_arn = aws_ram_resource_share.rs-tgw2.arn
}

# Accepting transit-VPC2's VPC attachment.
/*resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "transit-vpc2" {
  transit_gateway_attachment_id = var.transit-vpc2-attachment

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "transit-vpc2-Accepter"
  }

  depends_on = [var.transit-vpc2-attachment]
}

resource "aws_ec2_transit_gateway_route_table" "tgw2-rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw2.id
}*/

data "aws_ec2_transit_gateway_route_table" "tgw2-default-rtb" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tgw2.id]
  }

  depends_on = [aws_ec2_transit_gateway.tgw2]
}


resource "aws_ec2_transit_gateway_route" "tgw2-default-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.transit-vpc2-attachment
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw2-default-rtb.id

  depends_on = [data.aws_ec2_transit_gateway_route_table.tgw2-default-rtb]
}

resource "aws_ec2_transit_gateway_route" "tgw2-tgw1-route" {
  destination_cidr_block         = "10.4.0.0/14"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw1.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw2-default-rtb.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw1]
}

resource "aws_ec2_transit_gateway_route" "tgw2-tgw3-route" {
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw2-tgw3.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw2-default-rtb.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw2-tgw3]
}









