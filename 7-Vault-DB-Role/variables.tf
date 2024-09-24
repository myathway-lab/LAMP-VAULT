variable "lamp_username" {
  description = "The database username"
  type        = string
}

variable "lamp_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "db_ip" {
  description = "The database TCP IP address"
  type        = string
}