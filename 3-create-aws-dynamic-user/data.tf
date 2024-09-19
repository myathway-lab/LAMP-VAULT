data "terraform_remote_state" "vault_admin" {
  backend = "remote"

  config = {
    organization = "HCP-MyaThway"
    workspaces = {
      name = "AWS-IAM-Creation"
    }
  }
}


