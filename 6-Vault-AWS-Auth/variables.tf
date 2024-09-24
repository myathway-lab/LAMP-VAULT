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

variable "bound_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "bound_iam_instance_profile_arns" {
  description = "The list of IAM instance profile ARNs"
  type        = list(string)
}
