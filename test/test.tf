module "minimal" {
  source = "../"

  app_name                 = "app"
  app_env                  = "test"
  domain_name              = "example.com"
  container_def_json       = "{}"
  subdomain                = "app"
  default_cert_domain_name = "*.example.com"
}

module "full" {
  source = "../"

  app_env                  = "app"
  app_name                 = "test"
  domain_name              = "example.com"
  container_def_json       = "{}"
  create_cd_user           = true
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
  instance_type            = "t3.micro"
  create_adminer           = true
  enable_adminer           = true
  health_check = {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
  log_retention_in_days = 60
  asg_tags = {
    foo = "bar",
  }
}

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region = "us-east-1"
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
