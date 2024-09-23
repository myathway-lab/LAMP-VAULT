variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "Pub-Subnet-Web" {
  description = "Subnet ID for Web servers"
  type        = string
}

variable "Pri-Subnet-DB" {
  description = "Subnet ID for DB servers"
  type        = string
}

variable "Web-SecurityGroup-id" {
  description = "Security group for Web servers"
  type        = list(string)
}

variable "DB-SecurityGroup-id" {
  description = "Security group for DB servers"
  type        = list(string)
}

variable "iam_role" {
  description = "IAM role to attach to the instance"
  type        = string
}


variable "mysql_root_password" {
  description = "The root password for MySQL"
  type        = string
}

variable "mysql_lamp_password" {
  description = "lampuser password for MySQL"
  type        = string
}

variable "vault_addr" {
  description = "The address of the Vault server"
  type        = string
}

variable "db_ip" {
  description = "The address of the MySQL server"
  type        = string
}



