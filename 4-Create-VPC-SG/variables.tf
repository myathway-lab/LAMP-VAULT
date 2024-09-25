##################################################
# VPC
##################################################
variable "name" {
  description = "(Require) Name to be used on all the resources as identifier"
  type        = string
  default     = "VPC-LAMP"
}

variable "cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "(Optional) A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "azs" {
  description = "(Require) A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames Default: `true`"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support Default: `true`"
  type        = bool
  default     = true
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Environment" = "Production"
    "Project"     = "TFC-VAULT-AWS-Project"
    "Owner"       = "MyaThway"
  }
}

################################################################################
# Publiс Subnets for Web Servers
################################################################################

variable "public_subnets" {
  description = "A list of public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "create_multiple_public_route_tables" {
  description = "Indicates whether to create a separate route table for each public subnet. Default: `false`"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `false`"
  type        = bool
  default     = true
}

variable "public_subnet_names" {
  description = "Explicit values to use in the Name tag on public subnets."
  type        = list(string)
  default     = ["Pub-Subnet-WebServers"]
}




################################################################################
# Private Subnets for DB Servers
################################################################################

variable "private_subnets" {
  description = "A list of private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "private_subnet_names" {
  description = "Explicit values to use in the Name tag on private subnets."
  type        = list(string)
  default     = ["Pri-Subnet-WebServers"]
}


################################################################################
# NAT Gateway
################################################################################

variable "nat_gateway_destination_cidr_block" {
  description = "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route"
  type        = string
  default     = "0.0.0.0/0"
}

##############################################
#Vault
##############################################

variable "backend_path" {
  description = "Vault aws secret path"
  type        = string
  default     = "aws-master-account"
}

variable "vault_dynamic_role" {
  description = "Vault dynamic role"
  type        = string
  default     = "master-iamadmin-role"
}

variable "aws_region" {
  description = "AWS Region for Vault AWS Secret Role"
  default     = "ap-southeast-1"
}