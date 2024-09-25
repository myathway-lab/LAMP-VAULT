resource "aws_instance" "LAMP-MySQL" {
  ami                    = "ami-01811d4912b4ccb26"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.Pri-Subnet-DB
  vpc_security_group_ids = var.DB-SecurityGroup-id
  private_ip             = var.db_ip
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  user_data = templatefile("${path.module}/mysql_user_data.tpl", {
    mysql_root_password = var.mysql_root_password,
    mysql_lamp_password = var.mysql_lamp_password
  })


  tags = {
    Name = "LAMP-MySQL"
  }
}

