data "terraform_remote_state" "vault_admin" {
  backend = "remote"

  config = {
    organization = "Vault-AWS-LAMP"
    workspaces = {
      name = "2-Create-VaultAdmin-in-AWS"
    }
  }
}


