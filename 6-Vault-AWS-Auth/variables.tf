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

#variable "bound_account_ids" {
#  description = "The AWS account ID"
#  type        = string
#}

#variable "bound_iam_principal_arns" {
#  description = "ec2 attached iam role"
#  type        = list(string)
#}