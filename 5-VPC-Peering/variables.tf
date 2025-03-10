variable "aws_region" {
  description = "AWS Region for Vault AWS Secret Role"
  default     = "ap-southeast-1"
}

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
  default     = "vpc-00dcd0edfd3bb995d"
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
  default     = "rtb-0116d9a93f3983050"
}

variable "public_routetb_id" {
  description = "Web-RouteTable"
  type        = string
  default     = "rtb-0c1bd2bd4e133bff1"
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
