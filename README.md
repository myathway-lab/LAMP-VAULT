## **Workflow between GitHub, Terraform Cloud and HCP Cluster**

![image](https://github.com/user-attachments/assets/46530d3e-b781-42d3-912c-ceff98d02efd)

## **Workflow - VPC Peering between HCP Vault Cluster & AWS VPC Network**

![image](https://github.com/user-attachments/assets/d064c306-e86a-42e3-b68b-2898912acb7b)


## **Workflow - Securing LAMP Stack with Vault: Dynamic Credentials**

![image](https://github.com/user-attachments/assets/25cb794d-b5a3-4832-a8b4-7e32a9a6a30b)

![image](https://github.com/user-attachments/assets/275ab724-5241-4a66-964f-4a343f4821ee)

## **Expected Result**


https://github.com/user-attachments/assets/e94e62d6-d0a2-4d5c-af4d-367051bbc9f7


# Detailed Steps

<details>
<summary>## 1. Create HCP Vault Cluster</summary>

- Configure Vault cluster & HVN in HCP using Terraform.
- Terraform codes **- [*LAMP-VAULT/1-Create-HVN-Cluster at main · myathway-lab/LAMP-VAULT (github.com)*](https://github.com/myathway-lab/LAMP-VAULT/tree/main/1-Create-HVN-Cluster)**
    
    ```yaml
    resource "hcp_hvn" "mt-hcp-hvn" {
      hvn_id         = var.hvn_id
      cloud_provider = var.cloud_provider
      region         = var.region
    }
    
    resource "hcp_vault_cluster" "hcp_vault_cluster" {
      hvn_id          = hcp_hvn.mt-hcp-hvn.hvn_id
      cluster_id      = var.cluster_id
      tier            = var.tier
      public_endpoint = true
    }
    ```
    <details>

## **2. Create AWS IAM User**

- Create AWS IAM user call “**vault-admin**” for Vault administration.
- Generate Access / Secret Keys for programmatic access.
- Attached Inline policy that grants specific permissions related to IAM user management for users whose names start with “vault-”.
- Full Terraform codes - **[*https://github.com/myathway-lab/LAMP-VAULT/blob/main/2-create-aws-vaultadmin*](https://github.com/myathway-lab/LAMP-VAULT/blob/main/2-create-aws-vaultadmin)**
    - TF Code
        
        ```yaml
        provider "aws" {
          region = var.aws_region
        }
        
        resource "aws_iam_user" "vault_admin" {
          name = var.user_name
          path = "/"
        
          tags = {
            Name = var.user_name
          }
        }
        
        resource "aws_iam_access_key" "vault_admin_accesskey" {
          user = aws_iam_user.vault_admin.name
          lifecycle {
            ignore_changes = [
              user
            ]
          }
        }
        
        data "aws_iam_policy_document" "inline_po_vault" {
          statement {
            effect = "Allow"
            actions = [
              "iam:AttachUserPolicy",
              "iam:CreateUser",
              "iam:CreateAccessKey",
              "iam:DeleteUser",
              "iam:DeleteAccessKey",
              "iam:DeleteUserPolicy",
              "iam:DetachUserPolicy",
              "iam:GetUser",
              "iam:ListAccessKeys",
              "iam:ListAttachedUserPolicies",
              "iam:ListGroupsForUser",
              "iam:ListUserPolicies",
              "iam:PutUserPolicy",
              "iam:AddUserToGroup",
              "iam:RemoveUserFromGroup"
            ]
            resources = [
              "arn:aws:iam::010526263030:user/vault-*"
            ]
          }
        }
        
        resource "aws_iam_user_policy" "inline_po_attach" {
          name   = var.inline_po_name
          user   = aws_iam_user.vault_admin.name
          policy = data.aws_iam_policy_document.inline_po_vault.json
        }
        ```
        
    

## **3. Create Vault Roles for AWS Dynamic Credentials**

- In this lab, we will use Dynamic creds which is generated by Vault to authenticate with AWS.
- Dynamic creds are short-lived and automatically expire, reducing the risk of long-term exposure. Vault can automatically renew these credentials before they expire, ensuring continuous access without manual intervention. If needed, Vault can revoke the credentials at any time, immediately invalidating them.
- Configure the AWS secrets engine in Vault with specified credentials, region, path, and lease settings. The lifecycle block tells Terraform to ignore changes to the **`access_key`** and **`secret_key.`**  Vault will authenticate to AWS using “vault admin” account that we created in step2 [**2. Create AWS IAM User**](https://www.notion.so/2-Create-AWS-IAM-User-10cdb668cefb80d1bdebd24e3fc52b5d?pvs=21).
    
    ```
    resource "vault_aws_secret_backend" "aws" {
      description               = "Vault AWS Secret Engine Resource for AWS Master Account"
      access_key                = data.terraform_remote_state.vault_admin.outputs.vault_admin_accesskey
      secret_key                = data.terraform_remote_state.vault_admin.outputs.vault_admin_secret_accesskey
      region                    = var.aws_region
      path                      = var.secret_path.master_secret_path
      default_lease_ttl_seconds = 600
      max_lease_ttl_seconds     = 3000
      lifecycle {
        ignore_changes = [
          access_key, secret_key
        ]
      }
    }
    ```
    
- Configure a dynamic role in Vault’s AWS secrets engine that generates IAM user credentials with permissions to manage IAM, EC2, and STS resources.
    
    ```yaml
    resource "vault_aws_secret_backend_role" "iam_admin_dynamic_role" {
      backend         = vault_aws_secret_backend.aws.path
      name            = var.secret_role_name.master_iamadmin_role_name
      credential_type = var.credential_type.iam_user
      policy_document = <<EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "iam:*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:*",
          "Resource": "*"
        },   
        {
          "Effect": "Allow",
          "Action": "sts:*",
          "Resource": "*"
        }    
      ]
    }
    EOT
    }
    ```
    
- Once we configured AWS secret engine & confirmed dynamic creds are able to generate, we will rotate
- Full Terraform codes - **[*https://github.com/myathway-lab/LAMP-VAULT/blob/main/3-create-vault-dynamic-roles*](https://github.com/myathway-lab/LAMP-VAULT/blob/main/3-create-vault-dynamic-roles)**

## **4. Create AWS Network Resources**

- The `data "vault_aws_access_credentials" "master_iamadmin_creds"` block fetches temporary AWS cred from Vault dynamic role which we created in [**3. Create Vault Roles for AWS Dynamic Credentials**](https://www.notion.so/3-Create-Vault-Roles-for-AWS-Dynamic-Credentials-75d83997ccfc4e86b005c83a00368825?pvs=21).
- Terraform will use this dynamic cred to authenticate with AWS.
- Then create network resources and security groups for EC2 instances which we will setup in [**6. Create EC2 Instances**](https://www.notion.so/6-Create-EC2-Instances-10cdb668cefb80e5bf9de713dc5e9979?pvs=21).
- Terraform code **- [](https://github.com/myathway-lab/LAMP-VAULT/blob/main/4-Create-VPC-SG) *https://github.com/myathway-lab/LAMP-VAULT/blob/main/4-Create-VPC-SG***
    - Create a VPC with specified IP range, tenancy, DNS settings.
        
        ```yaml
        resource "aws_vpc" "main" {
          cidr_block           = var.cidr
          instance_tenancy     = var.instance_tenancy
          enable_dns_hostnames = var.enable_dns_hostnames
          enable_dns_support   = var.enable_dns_support
          tags = merge(
            { "Name" = var.name },
            var.tags
          )
        }
        ```
        
    - Create a public subnet within the above VPC, specifies the AZ, cidr_block and map_public_ip_on_launch to ensure that all the instances in this public subnet receive a public IP address.  Create route table and associate.
        
        ```
        resource "aws_vpc" "main" {
          cidr_block           = var.cidr
          instance_tenancy     = var.instance_tenancy
          enable_dns_hostnames = var.enable_dns_hostnames
          enable_dns_support   = var.enable_dns_support
          tags = merge(
            { "Name" = var.name },
            var.tags
          )
        }
        ```
        
    - Create a public subnet within the above VPC, specifies the AZ, cidr_block and map_public_ip_on_launch to ensure that all the instances in this public subnet receive a public IP address.  Create route table and associate.
        
        ```
        ################################################################################
        # Publiс Subnet For Web Servers
        ################################################################################
        
        resource "aws_subnet" "public" {
          count                   = local.len_public_subnets
          vpc_id                  = aws_vpc.main.id
          availability_zone       = data.aws_availability_zones.azs.names[0]
          cidr_block              = var.public_subnets[count.index]
          map_public_ip_on_launch = var.map_public_ip_on_launch
          tags = {
            Name = "Pub-Subnet-Web"
          }
        }
        
        resource "aws_route_table" "public" {
          vpc_id = aws_vpc.main.id
          tags = {
            Name = "RouteTable-Web"
          }
        }
        
        resource "aws_route_table_association" "public" {
          count          = local.len_public_subnets
          route_table_id = aws_route_table.public.id
          subnet_id      = aws_subnet.public[count.index].id
        
        }
        
        resource "aws_route" "public_internet_gateway" {
          route_table_id         = aws_route_table.public.id
          destination_cidr_block = "0.0.0.0/0"
          gateway_id             = aws_internet_gateway.this.id
          timeouts {
            create = "5m"
          }
        }
        
        ```
        
    - Create a private subnet within the above VPC, specifies the AZ, cidr_block. Create route table and associate.
        
        ```
        ###############################################################################
        # Private Subnets for DB Servers
        ################################################################################
        
        resource "aws_subnet" "private" {
          count             = local.len_private_subnets
          vpc_id            = aws_vpc.main.id
          availability_zone = data.aws_availability_zones.azs.names[1]
          cidr_block        = var.private_subnets[count.index]
          tags = {
            Name = "Pri-Subnet-DB"
          }
        }
        
        resource "aws_route_table" "private" {
          vpc_id = aws_vpc.main.id
          tags = {
            Name = "DB-RouteTable"
          }
        }
        
        resource "aws_route_table_association" "private" {
          count          = local.len_private_subnets
          route_table_id = aws_route_table.private.id
          subnet_id      = element(aws_subnet.private[*].id, count.index)
        }
        
        resource "aws_route" "private_nat_gateway" {
          route_table_id         = aws_route_table.private.id
          destination_cidr_block = var.nat_gateway_destination_cidr_block
          nat_gateway_id         = aws_nat_gateway.nat.id
          timeouts {
            create = "5m"
          }
        }
        
        ```
        
    - Create Internet gateway.
        
        ```
        ################################################################################
        # Internet Gateway
        ################################################################################
        
        resource "aws_internet_gateway" "this" {
          vpc_id = aws_vpc.main.id
          tags = merge(
            { "Name" = var.name },
            var.tags,
          )
        }
        ```
        
    - Create NAT gateway.
        
        ```
        ################################################################################
        # NAT Gateway
        ################################################################################
        
        resource "aws_eip" "nat" {
          domain     = "vpc"
          depends_on = [aws_internet_gateway.this]
        }
        
        resource "aws_nat_gateway" "nat" {
          allocation_id = aws_eip.nat.id
          subnet_id = element(
            aws_subnet.public[*].id, 0
          )
          depends_on = [aws_internet_gateway.this]
          tags = {
            Name = "LAMP NAT"
          }
        }
        ```
        
    - Security Group for Web Servers
        
        ```yaml
        ################################################################################
        # Security Group for Web Servers
        ################################################################################
        
        resource "aws_security_group" "Web-SecurityGroup" {
          name        = "Web-SecurityGroup"
          description = "Allow inbound and outbound traffic for Web servers"
          vpc_id      = aws_vpc.main.id
        
          tags = {
            Name = "Web-SecurityGroup"
          }
        }
        
        resource "aws_vpc_security_group_ingress_rule" "allow_http" {
          security_group_id = aws_security_group.Web-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          from_port         = 80
          ip_protocol       = "tcp"
          to_port           = 80
        }
        
        resource "aws_vpc_security_group_ingress_rule" "allow_https" {
          security_group_id = aws_security_group.Web-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          from_port         = 443
          ip_protocol       = "tcp"
          to_port           = 443
        }
        
        resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_all" {
          security_group_id = aws_security_group.Web-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          from_port         = 22
          ip_protocol       = "tcp"
          to_port           = 22
        }
        
        resource "aws_vpc_security_group_egress_rule" "allow_all" {
          security_group_id = aws_security_group.Web-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          ip_protocol       = "-1" # semantically equivalent to all ports
        }
        ```
        
    - Security Group for DB Servers
        
        ```yaml
        ################################################################################
        # Security Group for DB Servers
        ################################################################################
        
        resource "aws_security_group" "DB-SecurityGroup" {
          name        = "DB-SecurityGroup"
          description = "Allow inbound and outbound traffic for Db servers"
          vpc_id      = aws_vpc.main.id
        
          tags = {
            Name = "DB-SecurityGroup"
          }
        }
        
        resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
          for_each          = toset(var.public_subnets)
          security_group_id = aws_security_group.DB-SecurityGroup.id
          cidr_ipv4         = each.value
          from_port         = 22
          ip_protocol       = "tcp"
          to_port           = 22
        }
        
        resource "aws_vpc_security_group_ingress_rule" "allow_vault" {
          security_group_id = aws_security_group.DB-SecurityGroup.id
          cidr_ipv4         = "172.25.16.0/20"
          from_port         = 3306
          ip_protocol       = "tcp"
          to_port           = 3306
        }
        
        resource "aws_vpc_security_group_ingress_rule" "allow_websever" {
          security_group_id = aws_security_group.DB-SecurityGroup.id
          cidr_ipv4         = var.public_subnets[0] 
          from_port         = 3306
          ip_protocol       = "tcp"
          to_port           = 3306
        }
        
        resource "aws_vpc_security_group_egress_rule" "allow_http" {
          security_group_id = aws_security_group.DB-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          from_port         = 80
          ip_protocol       = "tcp"
          to_port           = 80
        }
        
        resource "aws_vpc_security_group_egress_rule" "allow_https" {
          security_group_id = aws_security_group.DB-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          from_port         = 443
          ip_protocol       = "tcp"
          to_port           = 443
        }
        
        resource "aws_vpc_security_group_egress_rule" "allow_vaultport" {
          security_group_id = aws_security_group.DB-SecurityGroup.id
          cidr_ipv4         = "0.0.0.0/0"
          from_port         = 8200
          ip_protocol       = "tcp"
          to_port           = 8200
        }
        ```
        

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f020007f-666a-401f-b7a3-4c1d3d9787c0/974fda8e-4df4-4e60-a937-f91cc8649e04/image.png)

## **5. VPC Peering between HVN & AWS**

- **Same as step 4, Terraform will use aws dynamic cred to authenticate with AWS.**
- **Establishes a peering connection between an HVN and an AWS VPC.**
- **Configures the necessary routes to enable communication between HVN and AWS VPC.**
- **Full Terraform code - [*https://github.com/myathway-lab/LAMP-VAULT/blob/main/5-VPC-Peering*](https://github.com/myathway-lab/LAMP-VAULT/blob/main/5-VPC-Peering)**
- Create HVN to AWS Peering
    
    ```yaml
    ###cretae hvn to aws peering###
    
    resource "hcp_aws_network_peering" "dev" {
      hvn_id          = var.hvn_id
      peering_id      = var.peering_id
      peer_vpc_id     = var.peer_vpc_id
      peer_account_id = var.owner_id
      peer_vpc_region = var.peer_region
    }
    ```
    
- To automatically accept the peering connection on the AWS.
    
    ```yaml
    resource "aws_vpc_peering_connection_accepter" "peer" {
      vpc_peering_connection_id = hcp_aws_network_peering.dev.provider_peering_id
      auto_accept               = true
    }
    ```
    
- Add Routes for HVN
    
    ```yaml
    resource "hcp_hvn_route" "hvn-to-aws-route" {
      hvn_link         = data.hcp_hvn.hvn_vault.self_link
      hvn_route_id     = "hvn-aws-route"
      destination_cidr = "10.0.0.0/16"
      target_link      = hcp_aws_network_peering.dev.self_link
    }
    ```
    
- Add Routes for AWS
    
    ```yaml
    resource "aws_route" "route_for_private" {
      route_table_id            = var.private_routetb_id
      destination_cidr_block    = data.hcp_hvn.hvn_vault.cidr_block
      vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
    }
    
    resource "aws_route" "route_for_public" {
      route_table_id            = var.public_routetb_id
      destination_cidr_block    = data.hcp_hvn.hvn_vault.cidr_block
      vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
    }
    ```
    

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f020007f-666a-401f-b7a3-4c1d3d9787c0/222e750e-8cb2-4063-a570-0976286ac361/image.png)

## **6. Create EC2 Instances**

- **Same as previous steps, Terraform will use dynamic creds generated from vault role to authenticate with AWS to deploy EC2 resources.**
- **Full Terraform codes - [](https://github.com/myathway-lab/LAMP-VAULT/blob/main/4-Create-VPC-SG) *https://github.com/myathway-lab/LAMP-VAULT/blob/main/6-Create-EC2-Instances***
- **Refer [Setup Apache/PHP server](https://www.notion.so/Setup-Apache-PHP-server-10cdb668cefb801480b1f7d8d090eff5?pvs=21) [Setup MySQL server](https://www.notion.so/Setup-MySQL-server-10cdb668cefb80738f67f99a3b843fd6?pvs=21) for detailed setup.**

> **We will setup LAMP (Linux, Apache, MySQL, PHP) stack on AWS with separate EC2 instances for MySQL and Apache/PHP.**
> 

> **Whenever the Apache service needs to authenticate with DB, it talks to Vault. Then Vault authenticates with DB and generate DB dynamic creds.**
> 

> **In this lab, we will use Vault Agent with auto-auth to automatically renew the dynamic creds before expiring. This ensures that web server always has valid credentials.**
> 
> 
> **Renewing the Vault Token: Vault agent uses vault aws auth role `vault-role-for-ec2role`to authenticate Vault server and obtain a Vault token. This token is then periodically renewed to ensure continuous access.**
> 
> **Renewing Database creds: Vault agent reads the database credentials from `database/creds/db-role` and writes them `var/www/html/db-creds.json` This ensures that database credentials are always up-to-date.**
> 
> - **vault-agent.hcl (Vault Agent Config)**
>     
>     ```
>     exit_after_auth = false
>     pid_file = "/var/run/vault-agent.pid"
>     
>     auto_auth {
>       method "aws" {
>           mount_path = "auth/aws"
>           config = {
>               type = "iam"
>               role = "vault-role-for-ec2role"
>           }
>       }
>     
>       sink "file" {
>           config = {
>               path = "/var/www/html/vault-token-via-agent"
>           }
>       }
>     }
>     
>     vault {
>       address = "${vault_addr}"
>     }
>     
>     template {
>       source      = "/etc/vault.d/db-creds-template.hcl"
>       destination = "/var/www/html/db-creds.json"  
>     }
>     ```
>     
> 
- **High-level workflow**

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f020007f-666a-401f-b7a3-4c1d3d9787c0/0da3e385-1c76-4d1b-8aaf-dd0939b2e7f8/image.png)

- **Detailed workflow**

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f020007f-666a-401f-b7a3-4c1d3d9787c0/f67abb49-7c57-4a3e-aaea-2a8aef3e1858/image.png)

- **Expected Result: “Automatically renew the dynamic creds before expiring & Ensures web server always has valid credentials”.**

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f020007f-666a-401f-b7a3-4c1d3d9787c0/a8de90b1-cd6b-4b37-a0d4-008a15ae9af7/image.png)

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f020007f-666a-401f-b7a3-4c1d3d9787c0/14d87c9c-f5c0-436a-b3f7-7ca7c7043263/image.png)

### Setup Apache/PHP server

- **Before we launch EC2, we need to create AWS IAM role named “aws-ec2role-for-vault-authmethod” for HCP Vault Dedicated auth method.**
- **Then launch Web server in public subnet.**
- **Attach a security group defined in ‣.**
- **Attach “aws-ec2role-for-vault-authmethod” IAM role in web server.**
- **Add user data.**
    
    **- Update the package manager & install Apache and PHP related packages.
    - Configures Vault Agent with AWS IAM method.**
    
    **- Use Vault’s Auto-Auth method using AWS IAM roles to allow Vault to automatically   authenticate and retrieve a token.**
    
    **- Write PHP Code “/var/www/html/phptest.php” to test DB Connection.**
    
    **- Write PHP Code “/var/www/html/usersubmission.php” to verify the DB dynamic user privileges to LAMP database.**
    
- **Setup Web Sever**
    
    ```yaml
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
    ```
    
- **web_user_data.tpl (user data for webserver)**
    
    ```yaml
    #!/bin/bash
    set -e
    sudo hostnamectl set-hostname LAMP-WEB
    sudo apt-get update -y
    sudo apt-get install apache2 -y 
    sudo apt-get install php libapache2-mod-php php-mysql php-curl php-gd php-json php-zip gpg wget -y
    sudo apt install mysql-client -y
    sudo wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vault
    
    # Create the Vault agent configuration file
    sudo cat <<EOF > /etc/vault.d/vault-agent.hcl
    exit_after_auth = false
    pid_file = "/var/run/vault-agent.pid"
    
    auto_auth {
      method "aws" {
          mount_path = "auth/aws"
          config = {
              type = "iam"
              role = "vault-role-for-ec2role"
          }
      }
    
      sink "file" {
          config = {
              path = "/var/www/html/vault-token-via-agent"
          }
      }
    }
    
    vault {
      address = "${vault_addr}"
    }
    
    template {
      source      = "/etc/vault.d/db-creds-template.hcl"
      destination = "/var/www/html/db-creds.json"  
    }
    EOF
    
    sudo chown vault:vault /etc/vault.d/vault-agent.hcl
    sudo chmod 600 /etc/vault.d/vault-agent.hcl
    
    # Read the DB role creds
    sudo cat <<EOF > /etc/vault.d/db-creds-template.hcl
    {
      "username": "{{ with secret "database/creds/db-role" }}{{ .Data.username }}{{ end }}",
      "password": "{{ with secret "database/creds/db-role" }}{{ .Data.password }}{{ end }}"
    }
    EOF
    
    sudo chown vault:vault /etc/vault.d/db-creds-template.hcl
    sudo chmod 600 /etc/vault.d/vault-agent.hcl
    
    ##Run vault agent as service 
    sudo cat <<EOF > /etc/systemd/system/vault-agent.service
    [Unit]
    Description=Vault Agent
    After=network.target
    
    [Service]
    Environment="VAULT_NAMESPACE=admin"
    Environment="VAULT_ADDR=${vault_addr}"
    
    ExecStart=/usr/bin/vault agent -config=/etc/vault.d/vault-agent.hcl
    Restart=on-failure
    
    [Install]
    WantedBy=multi-user.target
    EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable vault-agent
    sudo systemctl start vault-agent
    
    #Configure PHP code for dynamic DB cred check
    sudo cat <<'EOF' > /var/www/html/phptest1.php
    <?php
    // Enable error reporting
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    
    // Path to the JSON file with database credentials
    
    $credsFile = '/var/www/html/db-creds.json';
    
    // Read the JSON file
    $json = file_get_contents($credsFile);
    if ($json === false) {
        die("Failed to read credentials file.");
    }
    
    $creds = json_decode($json, true);
    if ($creds === null) {
        die("Failed to decode JSON.");
    }
    
    // Debugging output
    echo "Username: " . htmlspecialchars($creds['username']) . "<br>";
    echo "Password: " . htmlspecialchars($creds['password']) . "<br>";
    
    // Database connection parameters
    $servername = "${db_ip}"; // e.g., "localhost" or your server IP
    $username = $creds['username'];
    $password = $creds['password'];
    $dbname = "lamp"; // the name of your database
    
    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);
    
    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    echo "Connected successfully to the database.";
    ?>
    EOF
    
    #Configure PHP code for dynamic cred to verify the access
    sudo cat <<'EOF' > /var/www/html/usersubmission.php
    <?php
    // Enable error reporting
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    
    // Path to the JSON file with database credentials
    $credsFile = '/var/www/html/db-creds.json';
    
    // Read the JSON file
    $json = file_get_contents($credsFile);
    if ($json === false) {
        die("Failed to read credentials file.");
    }
    
    $creds = json_decode($json, true);
    if ($creds === null) {
        die("Failed to decode JSON.");
    }
    
    // Database connection parameters
    $servername = "10.0.2.217"; // e.g., "localhost" or your server IP
    $username = $creds['username'];
    $password = $creds['password'];
    $dbname = "lamp"; // the name of your database
    
    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);
    
    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    echo "Connected successfully to the database.<br>";
    
    // Handle form submission
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $user = $_POST['username'];
        $email = $_POST['email'];
        $pass = $_POST['password'];
    
        // Insert data into the users table
        $sql = "INSERT INTO users (username, email, password) VALUES ('$user', '$email', '$pass')";
    
        if ($conn->query($sql) === TRUE) {
            echo "New user created successfully. Below is the LAMP User List. <br>";
        } else {
            echo "Error: " . $sql . "<br>" . $conn->error;
        }
    }
    
    // Retrieve and display all users
    $sql = "SELECT id, username, email FROM users";
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        echo "<h3>Users List</h3>";
        echo "<table border='1'><tr><th>ID</th><th>Username</th><th>Email</th></tr>";
        while($row = $result->fetch_assoc()) {
            echo "<tr><td>" . $row["id"]. "</td><td>" . $row["username"]. "</td><td>" . $row["email"]. "</td></tr>";
        }
        echo "</table>";
    } else {
        echo "0 results";
    }
    
    $conn->close();
    ?>
    
    <!DOCTYPE html>
    <html>
    <head>
        <title>Register User</title>
    </head>
    <body>
        <h3>Register User</h3>
        <form method="post" action="">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required><br><br>
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required><br><br>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required><br><br>
            <input type="submit" name="submit" value="Register">
        </form>
    </body>
    </html>
    EOF 
    
    sudo systemctl restart vault-agent.service 
    sudo systemctl restart apache2
    ```
    

### Setup MySQL server

- **Launch MySQL server in private subnet and attach a security group defined in** ‣.
- **Add user data.**
    
     **- Update the package manager & install MySQL related packages.**
    
     **- Configure MySQL & allow remote client access.**
    
     **- Create “lampuser” in DB.**
    
     **- When webserver tries to access database, vault agent from webserver will read the DB-Role from Vault.** 
    
     **- DB-Role will use “lampuser” to authenticate with Database to generate dynamic user.** 
    
     **- So, we need to give “create user” and “drop” with “grant” privileges to “lampuser”.**
    
- **Launch DB Sever**
    
    ```yaml
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
    ```
    
- **mysql_user_data.tpl  (user data for db server)**
    
    ```yaml
    #!/bin/bash
    set -e
    sudo hostnamectl set-hostname LAMP-MySQL
    sudo apt-get update -y
    sudo apt-get install mysql-server -y
    # Secure MySQL installation
    sudo mysql_secure_installation <<EOF
    y
    0
    y
    y
    y
    y
    EOF
    
    # Login to MySQL with root user and empty password, then change the root password
    # root_password="${mysql_root_password}"
    
    root_password="${mysql_root_password}"
    
    sudo mysql -u root --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$root_password'; FLUSH PRIVILEGES;"
    
    # Run additional MySQL commands
    lamp_password="${mysql_lamp_password}"
    
    sudo mysql -u root -p"$root_password" <<EOF
    CREATE DATABASE lamp;
    CREATE USER 'lampuser'@'%' IDENTIFIED BY '$lamp_password';
    GRANT ALL PRIVILEGES ON lamp.* TO 'lampuser'@'%';
    GRANT DROP ON mysql.* TO 'lampuser'@'%' WITH GRANT OPTION;
    GRANT CREATE USER ON *.* TO 'lampuser'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    CREATE TABLE users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL,
        password VARCHAR(255) NOT NULL
    );
    EOF
    
    # Change the bind address to all to accept remote connection.
    sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    
    # Restart the mysql after config change.
    sudo systemctl restart mysql
    ```
    

## 7. Create Vault DB Role

- We need to make sure EC2 Webserver able to talk with vault to read the DB creds.
- In Vault server, we will enable database secret engine, configure database connection and create role for dynamic creds.
- Vault agent inside EC2 webserver will read the role and get dynamic creds from vault.
- **Full Terraform codes - [*https://github.com/myathway-lab/LAMP-VAULT/blob/main/7-Create-Vault-DB-Role*](https://github.com/myathway-lab/LAMP-VAULT/blob/main/7-Create-Vault-DB-Role)**

- Enable database secrets engine at the path “database”
    
    ```yaml
    resource "vault_mount" "db" {
      path = "database"
      type = "database"
      description = "This is for mysql db secret engine."
    }
    ```
    
- Sets up the connection to the MySQL database
    
    ```yaml
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
    ```
    
- Defines a role that can create users in the MySQL database & grant all privileges to lamp database.
    
    ```yaml
    resource "vault_database_secret_backend_role" "db-role" {
      backend             = vault_mount.db.path
      name                = "db-role"
      db_name             = vault_database_secret_backend_connection.lamp-mysql-db.name
      creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT ALL PRIVILEGES ON lamp.* TO '{{name}}'@'%';"]
      default_ttl         = "180"
      max_ttl             = "300"
    }
    ```
    

## 8. Enable Vault AWS Auth

- For AWS EC2 instances to authenticate with Vault, we can use **AWS auth method**. This method supports two types of authentications, “**IAM Method**” & “**EC2 Method**”.
- In this scenario, we will use AWS auth **IAM method** using **Vault Agent**.
- Please refer vault agent setup in [Setup Apache/PHP server](https://www.notion.so/Setup-Apache-PHP-server-10cdb668cefb801480b1f7d8d090eff5?pvs=21)
- **Full Terraform codes - [*https://github.com/myathway-lab/LAMP-VAULT/blob/main/7-Create-Vault-DB-Role*](https://github.com/myathway-lab/LAMP-VAULT/blob/main/7-Create-Vault-DB-Role)**

- Enable the AWS authentication method in Vault
    
    ```yaml
    resource "vault_auth_backend" "aws" {
      type = "aws"
    }
    ```
    
- Configure the AWS client with the necessary access and secret keys to authenticate with Vault.
    
    ```yaml
    resource "vault_aws_auth_backend_client" "client" {
      backend    = vault_auth_backend.aws.path
      access_key = data.vault_aws_access_credentials.master_iamadmin_creds.access_key
      secret_key = data.vault_aws_access_credentials.master_iamadmin_creds.secret_key
    }
    ```
    
- Define a policy that grants read access to the database credentials at the specified path.
    
    ```yaml
    resource "vault_policy" "vault-policy-for-ec2role" {
      name = "vault-policy-for-ec2role"
      policy = <<EOT
    path "database/creds/db-role" {
      capabilities = ["read"]
    }
    EOT
    }
    ```
    
- Create a role that allows EC2 instances with the specified IAM role to authenticate with Vault and obtain tokens with the defined policy.
    
    ```yaml
    resource "vault_aws_auth_backend_role" "vault-role-for-ec2role" {
      backend                         = vault_auth_backend.aws.path
      role                            = "vault-role-for-ec2role"
      auth_type                       = "iam"
      bound_iam_principal_arns        = ["arn:aws:iam::010526263030:role/aws-ec2role-for-vault-authmethod"]
      token_ttl                       = 120
      token_max_ttl                   = 300
      token_policies                  = ["vault-policy-for-ec2role"]
    }
    ```
    

https://www.digitalocean.com/community/tutorials/how-to-install-lamp-stack-on-ubuntu

https://usefulangle.com/post/324/aws-ec2-install-linux-apache-mysql-php-phpmyadmin-lamp-stack-ubuntu-20-04
