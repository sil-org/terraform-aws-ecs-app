
mock_provider "aws" {
  mock_data "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:111111111111:certificate/11111111-1111-1111-1111-111111111111"
    }
  }
  mock_resource "aws_alb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:111111111111:loadbalancer/app/alb-app-test/0000000000000000"
    }
  }
  mock_resource "aws_alb_listener" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:111111111111:listener/app/alb-app-test/0000000000000000/0000000000000000"
    }
  }
  mock_resource "aws_alb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:111111111111:targetgroup/default-app-test/0000000000000000"
    }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:111111111111:log-group:app-test"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::111111111111:role/test-role"
    }
  }
  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-11111111111111111"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "cloudflare" {}
variables {
  # required variables
  app_env                  = "test"
  app_name                 = "app"
  container_def_json       = ""
  default_cert_domain_name = ""
  domain_name              = ""
  subdomain                = ""
}

run "test" {
  assert {
    condition     = length(aws_iam_user.cd) == 0
    error_message = "CD IAM user should not be created when create_cd_user is false"
  }
  assert {
    condition     = length(aws_iam_role.cd) == 0
    error_message = "CD IAM role should not be created when create_cd_role is false"
  }
}

run "test_cd_role" {
  variables {
    create_cd_role = true
  }
  assert {
    condition     = length(aws_iam_role.cd) == 1
    error_message = "CD IAM role should be created when create_cd_role is true"
  }
}
