terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.65.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}


provider "aws" {
  region = var.peer_region
  access_key = data.vault_aws_access_credentials.master-networkadmin-cred.access_key
  secret_key = data.vault_aws_access_credentials.master-networkadmin-cred.secret_key
}
