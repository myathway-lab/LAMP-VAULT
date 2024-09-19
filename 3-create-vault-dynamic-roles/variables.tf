# variable "AWS_ACCESS_KEY_ID" {
#     description = "AWS Access Key for Vault AWS Secret Role"
# }

# variable "AWS_SECRET_ACCESS_KEY" {
#     description = "AWS Secret Access Key for Vault AWS Secret Role"
# }

variable "aws_region" {
  description = "AWS Region for Vault AWS Secret Role"
  default     = "ap-southeast-1"
}

variable "secret_path" {
  description = "AWS Secret Engine Path"
  type        = map(any)
  default = {
    "master_secret_path" = "aws-master-account"
  }
}

variable "secret_role_name" {
  description = "AWS Secret Engine Role Name"
  type        = map(any)
  default = {
    "master_netadmin_role_name" = "master-networkadmin-role"
    "master_iamadmin_role_name" = "master-iamadmin-role"
    "master_ec2admin_role_name" = "master-ec2admin-role"
    "master_rdsadmin_role_name" = "master-rdsadmin-role"
  }
}

variable "credential_type" {
  description = "AWS Secret Engile Role Credential Type"
  type        = map(any)
  default = {
    "iam_user"         = "iam_user"
    "assumed_role"     = "assumed_role"
    "federation_token" = "federation_token"
  }
}

variable "policy_arns_name" {
  description = "List of AWS Policy ARN Name"
  type        = map(any)
  default = {
    "networkadmin" = ["arn:aws:iam::aws:policy/AmazonVPCFullAccess"]
    "iamadmin"     = ["arn:aws:iam::aws:policy/IAMFullAccess"]
    "ec2admin"     = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
    "rdsadmin"     = ["arn:aws:iam::aws:policy/AmazonRDSFullAccess"]
  }
}


