
/*
 * Create VPC
 */
module "vpc" {
  source  = "sil-org/vpc/aws"
  version = "~> 1.1"

  app_name    = var.app_name
  app_env     = var.app_env
  aws_zones   = var.aws_zones
  enable_ipv6 = var.enable_ipv6
}

/*
 * Security group to limit traffic to Cloudflare IPs
 */

resource "aws_security_group" "cloudflare" {
  name        = "cloudflare-https"
  description = "Allow HTTPS traffic from Cloudflare"
  vpc_id      = module.vpc.id
  tags = {
    Name = "${local.app_name_and_env}-cloudflare"
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "2m"
  }
}

resource "aws_security_group_rule" "cloudflare" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cloudflare.id
  cidr_blocks       = split(",", data.external.cloudflare_ips.result.ipv4_cidrs)
  ipv6_cidr_blocks  = split(",", data.external.cloudflare_ips.result.ipv6_cidrs)
}

data "external" "cloudflare_ips" {
  program = ["${path.module}/cloudflare-ips.sh"]
}

moved {
  from = module.cloudflare-sg.aws_security_group.cloudflare_https
  to   = aws_security_group.cloudflare
}

moved {
  from = module.cloudflare-sg.aws_security_group_rule.cloudflare
  to   = aws_security_group_rule.cloudflare
}

/*
 * Create CloudFlow Logs to CloudWatch
 */
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "${local.app_name_and_env}-vpc-flow-log"
  retention_in_days = "30"
}

resource "aws_iam_role" "vpc_flow_log" {
  name = "VPCFlowLog-${local.app_name_and_env}-${local.region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "vpc_flow_log" {
  name = "VPCFlowLog"
  role = aws_iam_role.vpc_flow_log.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

/*
 * Get ssl cert for use with listener
 */
data "aws_acm_certificate" "default" {
  domain = var.default_cert_domain_name
}

/*
 * Create application load balancer for public access
 */
module "alb" {
  source  = "sil-org/alb/aws"
  version = "~> 2.0"

  app_name            = var.app_name
  app_env             = var.app_env
  enable_ipv6         = var.enable_ipv6
  disable_public_ipv4 = var.disable_public_ipv4
  internal            = "false"
  vpc_id              = module.vpc.id
  security_groups = [
    module.vpc.vpc_default_sg_id,
    var.use_cloudflare_sg ? aws_security_group.cloudflare.id : one(aws_security_group.public_https[*].id)
  ]
  subnets         = module.vpc.public_subnet_ids
  certificate_arn = data.aws_acm_certificate.default.arn
  tg_name         = "default-${var.app_name}-${var.app_env}"
}


/*
 * Create security group to allow public access to HTTPS. Used when var.use_cloudflare_sg is false.
 */
resource "aws_security_group" "public_https" {
  count = var.use_cloudflare_sg ? 0 : 1

  name        = "public-https"
  description = "Allow HTTPS traffic from public"
  vpc_id      = module.vpc.id
  tags = {
    Name = "public-https-${local.app_name_and_env}"
  }
}

resource "aws_security_group_rule" "public_https" {
  count = var.use_cloudflare_sg ? 0 : 1

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = one(aws_security_group.public_https[*].id)
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}


/*
 * Create ECS Cluster and Auto-Scaling Group
 * https://registry.terraform.io/modules/sil-org/ecs-asg/aws
 */
module "ecsasg" {
  source  = "sil-org/ecs-asg/aws"
  version = "~> 5.1"

  cluster_name                   = local.app_name_and_env
  subnet_ids                     = module.vpc.private_subnet_ids
  security_group_ids             = [module.vpc.vpc_default_sg_id]
  min_size                       = var.asg_min_size
  max_size                       = var.asg_max_size
  scaling_metric_name            = "MemoryReservation"
  alarm_actions_enabled          = var.alarm_actions_enabled
  ssh_key_name                   = var.ssh_key_name
  instance_type                  = var.instance_type
  tags                           = var.asg_tags
  enable_ipv6                    = var.enable_ipv6
  enable_ec2_detailed_monitoring = var.enable_ec2_detailed_monitoring
  additional_user_data           = var.asg_additional_user_data
}
