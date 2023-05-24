module "minimal" {
  source = "../"

  app_name                 = "app"
  app_env                  = "test"
  deploy_user_arn          = "arn"
  domain_name              = "example.com"
  container_def_json       = "{}"
  subdomain                = "app"
  default_cert_domain_name = "*.example.com"
}

module "full" {
  source = "../"

  app_env                  = "app"
  app_name                 = "test"
  deploy_user_arn          = "arn"
  aws_region               = "us-west-2"
  domain_name              = "example.com"
  container_def_json       = "{}"
  create_dns_record        = false
  database_name            = "app_db"
  database_user            = "root_user"
  desired_count            = 2
  subdomain                = "app"
  create_dashboard         = false
  asg_min_size             = "2"
  asg_max_size             = "3"
  alarm_actions_enabled    = true
  ssh_key_name             = "ssh"
  aws_zones                = ["us-west-2a"]
  default_cert_domain_name = "*.example.com"
}

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region = "us-east1"
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
    cloudflare = {
      version = "~> 3.0"
      source  = "cloudflare/cloudflare"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
  }
}
