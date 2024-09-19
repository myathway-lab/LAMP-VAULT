variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "mt-hcp-hvn"
}

variable "cluster_id" {
  description = "The ID of the HCP Vault cluster."
  type        = string
  default     = "vault-cluster"
}

variable "region" {
  description = "The region of the HCP HVN and Vault cluster."
  type        = string
  default     = "ap-southeast-1"
}

variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Vault cluster."
  type        = string
  default     = "aws"
}

variable "tier" {
  description = "Tier of the HCP Vault cluster. Valid options for tiers."
  type        = string
  default     = "dev"
}


