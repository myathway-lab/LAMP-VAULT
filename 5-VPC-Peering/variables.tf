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
  default     = "vpc-0b00da58569e26288"
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
  description = "DB-RouteTable"
  type        = string
  default     = "rtb-04e5d2876ac99a4da"
}

variable "public_routetb_id" {
  description = "Web-RouteTable"
  type        = string
  default     = "rtb-06ddcc39b0c2ec146"
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