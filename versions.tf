
terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.22.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
  }
}
