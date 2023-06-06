locals {
  app_name_and_env = "${var.app_name}-${local.app_env}"
  app_env          = var.app_env

  db_host     = module.rds.address
  db_password = random_password.db_root.result

  account = data.aws_caller_identity.this.account_id
  region  = data.aws_region.current.name
}

/*
 * Create user for CI/CD to perform ECS actions
 */
resource "aws_iam_user" "cd" {
  count = var.create_cd_user ? 1 : 0

  name = "cd-${local.app_name_and_env}"
}

resource "aws_iam_access_key" "cd" {
  count = var.create_cd_user ? 1 : 0

  user = aws_iam_user.cd[0].name
}

resource "aws_iam_user_policy" "cd" {
  count = var.create_cd_user ? 1 : 0

  name = "ecs_deployment"
  user = aws_iam_user.cd[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:RegisterTaskDefinition",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
        ]
        Resource = "arn:aws:ecs:${local.region}:${local.account}:service/${module.ecsasg.ecs_cluster_name}/${module.ecs.service_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTasks",
          "ecs:StopTask",
        ]
        Resource = "arn:aws:ecs:${local.region}:${local.account}:task/${module.ecsasg.ecs_cluster_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ListTasks",
        ]
        Resource = "arn:aws:ecs:${local.region}:${local.account}:container-instance/${module.ecsasg.ecs_cluster_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:StartTask",
        ]
        Resource = "arn:aws:ecs:${local.region}:${local.account}:task-definition/${module.ecs.task_def_family}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = module.ecsasg.ecsServiceRole_arn
      },
    ]
  })
}

/*
 * Create Cloudwatch log group
 */
resource "aws_cloudwatch_log_group" "logs" {
  name              = local.app_name_and_env
  retention_in_days = 30
}

/*
 * Create target group for ALB
 */
resource "aws_alb_target_group" "tg" {
  name                 = substr("tg-${local.app_name_and_env}", 0, 32)
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = module.vpc.id
  deregistration_delay = "30"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path    = "/"
    matcher = "302"
  }
}

/*
 * Create listener rule for hostname routing to new target group
 */
resource "aws_alb_listener_rule" "tg" {
  listener_arn = module.alb.https_listener_arn
  priority     = "218"

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${var.subdomain}.${var.domain_name}"]
    }
  }
}

/*
 *  Create cloudwatch dashboard for service
 */
module "ecs-service-cloudwatch-dashboard" {
  count = var.create_dashboard ? 1 : 0

  source  = "silinternational/ecs-service-cloudwatch-dashboard/aws"
  version = "~> 3.0.1"

  cluster_name   = module.ecsasg.ecs_cluster_name
  dashboard_name = local.app_name_and_env
  service_names  = [var.app_name]
}

/*
 * Create RDS root password
 */
resource "random_password" "db_root" {
  length = 16
}

/*
 * Create an RDS database
 */
module "rds" {
  source = "github.com/silinternational/terraform-modules//aws/rds/mariadb?ref=8.2.1"

  app_name          = var.app_name
  app_env           = local.app_env
  db_name           = var.database_name
  db_root_user      = var.database_user
  db_root_pass      = random_password.db_root.result
  subnet_group_name = module.vpc.db_subnet_group_name
  security_groups   = [module.vpc.vpc_default_sg_id]

  allocated_storage = 20 // 20 gibibyte
  instance_class    = "db.t3.micro"
  multi_az          = true
}

/*
 * Create new ecs service
 */
module "ecs" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only?ref=8.2.1"
  cluster_id         = module.ecsasg.ecs_cluster_id
  service_name       = var.app_name
  service_env        = local.app_env
  container_def_json = var.container_def_json
  desired_count      = var.desired_count
  tg_arn             = aws_alb_target_group.tg.arn
  lb_container_name  = "hub"
  lb_container_port  = "80"
  ecsServiceRole_arn = module.ecsasg.ecsServiceRole_arn
}

/*
 * Create Cloudflare DNS record
 */
resource "cloudflare_record" "dns" {
  count = var.create_dns_record ? 1 : 0

  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.subdomain
  value   = module.alb.dns_name
  type    = "CNAME"
  proxied = true
}

data "cloudflare_zones" "domain" {
  filter {
    name        = var.domain_name
    lookup_type = "exact"
    status      = "active"
  }
}


/*
 * AWS data
 */

data "aws_caller_identity" "this" {}

data "aws_region" "current" {}
