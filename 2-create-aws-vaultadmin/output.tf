output "vault_admin_id" {
  description = "Vault Admin IAM User ID"
  value       = aws_iam_user.vault_admin.id
}

output "vault_admin_arn" {
  description = "Vault Admin IAM User ARN"
  value       = aws_iam_user.vault_admin.arn
}

output "vault_admin_name" {
  description = "Vault Admin IAM User Name"
  value       = aws_iam_user.vault_admin.name
}

output "vault_admin_accesskey" {
  description = "Vault Admin IAM User Access Key"
  value       = aws_iam_access_key.vault_admin_accesskey.id
}

output "vault_admin_secret_accesskey" {
  description = "Vault Admin IAM User Secret Access Key"
  value       = aws_iam_access_key.vault_admin_accesskey.secret
  sensitive   = true
}

output "vault_admin_encrypt_secret_accesskey" {
  description = "Vault Admin IAM User Encrypted Secret Access Key"
  value       = aws_iam_access_key.vault_admin_accesskey.encrypted_secret
}