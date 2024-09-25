terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}



data "vault_aws_access_credentials" "master_iamadmin_creds" {
  backend = var.backend_path
  role    = var.vault_dynamic_role
}