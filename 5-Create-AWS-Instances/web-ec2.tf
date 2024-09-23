terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}


resource "aws_instance" "LAMP-WEB" {
  ami                         = "ami-01811d4912b4ccb26"
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.Pub-Subnet-Web
  vpc_security_group_ids      = var.Web-SecurityGroup-id
  iam_instance_profile        = var.iam_role
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  user_data = templatefile("${path.module}/web_user_data.tpl", {
    vault_addr = var.vault_addr,
    db_ip = var.db_ip
  })

  tags = {
    Name = "LAMP-WEB"
  }
}


resource "aws_eip" "LAMP-WEB-EIP" {
  vpc      = true
  instance = aws_instance.LAMP-WEB.id
}

