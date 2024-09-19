output "hvn" {
  value = {
    id         = hcp_hvn.mt-hcp-hvn.id
    region     = hcp_hvn.mt-hcp-hvn.region
    cidr_block = hcp_hvn.mt-hcp-hvn.cidr_block
  }
  description = "HVN attributes"
}
