variable "aws_region" {
  description = "AWS Region for Vault AWS Secret Role"
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vault_addr" {
  description = "The address of the Vault server"
  type        = string
}

variable "db_ip" {
  description = "The address of the MySQL server"
  type        = string
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
