output "web_instance_id" {
  description = "ID of the Web EC2 instance"
  value       = aws_instance.LAMP-WEB.id
}

output "web_instance_public_ip" {
  description = "Public IP address of the Web EC2 instance"
  value       = aws_instance.LAMP-WEB.public_dns
}

output "db_instance_id" {
  description = "ID of the DB EC2 instance"
  value       = aws_instance.LAMP-MySQL.id
}

output "db_instance_private_ip" {
  description = "Private IP address of the DB EC2 instance"
  value       = aws_instance.LAMP-MySQL.private_ip
}
