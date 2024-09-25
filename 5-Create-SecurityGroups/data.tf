data "vault_aws_access_credentials" "master_iamadmin_creds" {
  backend = var.backend_path
  role    = var.vault_dynamic_role
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}