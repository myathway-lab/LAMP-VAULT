data "hcp_hvn" "hvn_vault" {
  hvn_id = var.hvn_id
}

data "vault_aws_access_credentials" "master-networkadmin-cred" {
  backend = var.backend_path
  role    = var.vault_dynamic_role
}
