variable "hvn_id" {
  description = "HVN ID"
  type        = string
  default     = "mt-hcp-hvn"
}

variable "peering_id" {
  description = "HVN to AWS VPC peering"
  type        = string
  default     = "hcp-aws-peering"
}

variable "peer_vpc_id" {
  description = "AWS VPC ID"
  type        = string
  default     = "vpc-0f7a1cc45b21861c3"
}

variable "owner_id" {
  description = "VPC Owner ID"
  type        = string
  default     = "010526263030"
}

variable "peer_region" {
  description = "VPC Peer Region"
  type        = string
  default     = "ap-southeast-1"
}


variable "private_routetb_id" {
  description = "DB-NAT-RouteTable"
  type        = string
  default     = "rtb-0e40b1f79c8cb927b"
}

variable "public_routetb_id" {
  description = "RouteTable-Web"
  type        = string
  default     = "rtb-0cdd5a56ef06bb166"
}

variable "backend_path" {
  description = "Vault aws secret path"
  type        = string
  default     = "aws-master-account"
}

variable "vault_dynamic_role" {
  description = "Vault dynamic role"
  type        = string
  default     = "master-iamadmin-role"
}