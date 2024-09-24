resource "vault_mount" "db" {
  path = "database"
  type = "mysql"
  description = "This is for mysql db secret engine."
}

resource "vault_database_secret_backend_connection" "lamp-mysql-db" {
  backend           = vault_mount.db.path
  name              = "lamp-mysql-db"
  allowed_roles     = ["db-role"]
  verify_connection = true
  mysql{
    connection_url  = "{{username}}:{{password}}@tcp(${var.db_ip}:3306)/"
    username          = var.lamp_username
    password          = var.lamp_password
  }
}

resource "vault_database_secret_backend_role" "db-role" {
  backend             = vault_mount.db.path
  name                = "db-role"
  db_name             = vault_database_secret_backend_connection.lamp-mysql-db.name
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT ALL PRIVILEGES ON lamp.* TO '{{name}}'@'%';"]
  default_ttl         = "180"
  max_ttl             = "300"
}