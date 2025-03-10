terraform {
  required_providers {
    hcp = {
      source = "hashicorp/hcp"
      version = "0.104.0"
    }
  }
}

provider "hcp" {
}
