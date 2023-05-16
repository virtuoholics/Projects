resource "aws_ec2_transit_gateway" "tgw3" {

  #default_route_table_association = "disable"
  #default_route_table_propagation = "disable"
  auto_accept_shared_attachments = "disable" #default

  tags = {
    Name = "tgw-us-east-2"
  }
}

##### ENABLING RESOURCE SHARE FOR MULTI-ACCOUNT SETUP #####

resource "aws_ram_resource_share" "rs-tgw3" {
  name                      = "rs-us-east-2"
  allow_external_principals = true

  tags = {
    Name = "rs-us-east-2"
  }
}

# Sharing transit gateway...
resource "aws_ram_resource_association" "rs-tgw3" {
  resource_arn       = aws_ec2_transit_gateway.tgw3.arn
  resource_share_arn = aws_ram_resource_share.rs-tgw3.arn
}

# ...with tenant3-1
resource "aws_ram_principal_association" "tenant3-1" {
  principal          = var.cid-tenant3-1
  resource_share_arn = aws_ram_resource_share.rs-tgw3.arn
}

# ...with tenant3-2
resource "aws_ram_principal_association" "tenant3-2" {
  principal          = var.cid-tenant3-2
  resource_share_arn = aws_ram_resource_share.rs-tgw3.arn
}

##### DISABLING AUTO-ACCEPTANCE OF VPC ATTACHMENTS #####

/*
# Accepting tenant3's VPC attachments.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "tenant3-1" {
  transit_gateway_attachment_id = var.tenant3-attachment1

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "tenant3-vpc1-Accepter"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "tenant3-2" {
  transit_gateway_attachment_id = var.tenant3-attachment2

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "tenant3-vpc2--Accepter"
  }
}

# Accepting transit-VPC3's VPC attachment.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "transit-vpc3" {
  transit_gateway_attachment_id = var.transit-vpc3-attachment

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Side = "transit-vpc3-Accepter"
  }

  depends_on = [var.transit-vpc3-attachment]
}

resource "aws_ec2_transit_gateway_route_table" "tgw3-rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw3.id
}*/

data "aws_ec2_transit_gateway_route_table" "tgw3-default-rtb" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tgw3.id]
  }

  depends_on = [aws_ec2_transit_gateway.tgw3]
}

resource "aws_ec2_transit_gateway_route" "tgw3-default-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.transit-vpc3-attachment
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw3-default-rtb.id

  depends_on = [data.aws_ec2_transit_gateway_route_table.tgw3-default-rtb]
}

resource "aws_ec2_transit_gateway_route" "tgw3-tgw1-route" {
  destination_cidr_block         = "10.4.0.0/14"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw1.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw3-default-rtb.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw1]
}

/*resource "aws_ec2_transit_gateway_route" "tgw3-tgw2-route" {
  destination_cidr_block         = "10.0.0.0/14"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw2.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw3-default-rtb.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw2]
}*/









