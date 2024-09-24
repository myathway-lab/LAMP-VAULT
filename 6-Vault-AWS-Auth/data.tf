provider "aws" {
  region = var.aws_region
  access_key = data.vault_aws_access_credentials.master_iamadmin_creds.access_key
  secret_key = data.vault_aws_access_credentials.master_iamadmin_creds.secret_key
}

data "vault_aws_access_credentials" "master_iamadmin_creds" {
  backend = var.backend_path
  role    = var.vault_dynamic_role
}