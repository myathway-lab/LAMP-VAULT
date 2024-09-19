###############################
###cretae hvn to aws peering###

resource "hcp_aws_network_peering" "dev" {
  hvn_id          = var.hvn_id
  peering_id      = var.peering_id
  peer_vpc_id     = var.peer_vpc_id
  peer_account_id = var.owner_id
  peer_vpc_region = var.peer_region
}


resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.dev.provider_peering_id
  auto_accept               = true
}

###Add route for HVN###

resource "hcp_hvn_route" "hvn-to-aws-route" {
  hvn_link         = data.hcp_hvn.hvn_vault.self_link
  hvn_route_id     = "hvn-aws-route"
  destination_cidr = "10.0.0.0/16"
  target_link      = hcp_aws_network_peering.dev.self_link
}


###Add route for AWS###

resource "aws_route" "route_for_private" {
  route_table_id            = var.private_routetb_id
  destination_cidr_block    = data.hcp_hvn.hvn_vault.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "route_for_public" {
  route_table_id            = var.public_routetb_id
  destination_cidr_block    = data.hcp_hvn.hvn_vault.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

