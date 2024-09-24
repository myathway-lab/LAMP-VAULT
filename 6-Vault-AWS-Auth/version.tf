terraform {
  required_providers {
#    aws = {
#      source = "hashicorp/aws"
#      version = "5.68.0"
#    }
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

#provider "aws" {
#  region = var.aws_region
#  access_key = data.vault_aws_access_credentials.master_iamadmin_creds.access_key
#  secret_key = data.vault_aws_access_credentials.master_iamadmin_creds.secret_key
#}

data "vault_aws_access_credentials" "master_iamadmin_creds" {
  backend = var.backend_path
  role    = var.vault_dynamic_role
}

