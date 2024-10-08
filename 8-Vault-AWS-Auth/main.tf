##vault auth enable aws
resource "vault_auth_backend" "aws" {
  type = "aws"
}

###vault write auth/aws/config/client
resource "vault_aws_auth_backend_client" "client" {
  backend    = vault_auth_backend.aws.path
  access_key = data.vault_aws_access_credentials.master_iamadmin_creds.access_key
  secret_key = data.vault_aws_access_credentials.master_iamadmin_creds.secret_key
}


resource "vault_policy" "vault-policy-for-ec2role" {
  name = "vault-policy-for-ec2role"
  policy = <<EOT
path "database/creds/db-role" {
  capabilities = ["read"]
}
EOT
}


resource "vault_aws_auth_backend_role" "vault-role-for-ec2role" {
  backend                         = vault_auth_backend.aws.path
  role                            = "vault-role-for-ec2role"
  auth_type                       = "iam"
  bound_iam_principal_arns        = ["arn:aws:iam::010526263030:role/aws-ec2role-for-vault-authmethod"]
  token_ttl                       = 120
  token_max_ttl                   = 300
  token_policies                  = ["vault-policy-for-ec2role"]
}