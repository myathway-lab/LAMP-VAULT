output "dynamic_role" {
  description = "Read the Master NetworkAdmin Role"
  value       = resource.vault_aws_secret_backend_role.iam_admin_dynamic_role
}
#
#
#output "backend_path" {
#  description = "Output of Vault Secret Backend Path"
#  value = vault_aws_secret_backend.aws.path
#}
#
#output "backend_role_iam" {
#  description = "Output of Vault Secret Backend IAM Admin Role Name"
#  value = vault_aws_secret_backend_role.iam_admin_dynamic_role.name
#}
#
#output "backend_role_net" {
#  description = "Output of Vault Secret Backend Network Admin Role Name"
#  value = vault_aws_secret_backend_role.network_admin_dynamic_role.name
#}
#
#output "backend_role_ec2" {
#  description = "Output of Vault Secret Backend EC2 Admin Role Name"
#  value = vault_aws_secret_backend_role.ec2_admin_dynamic_role.name
#}
#
#output "backend_role_rds" {
#  description = "Output of Vault Secret Backend EC2 Admin Role Name"
#  value = vault_aws_secret_backend_role.rds_admin_dynamic_role.name
#}