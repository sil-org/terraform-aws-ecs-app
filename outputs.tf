
output "alb_dns_name" {
  value = module.alb.dns_name
}

output "app_url" {
  value = "https://${var.subdomain}.${var.domain_name}"
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.logs.name
}

output "database_arn" {
  value = aws_db_instance.this.arn
}

output "database_host" {
  value = aws_db_instance.this.address
}

output "database_password" {
  value     = local.db_password
  sensitive = true
}

output "adminer_url" {
  value = one(module.adminer[*].adminer_url)
}

output "ecsInstanceRole_arn" {
  value = module.ecsasg.ecsInstanceRole_arn
}

output "ecsServiceRole_arn" {
  value = module.ecsasg.ecsServiceRole_arn
}

output "cd_user_arn" {
  value = one(aws_iam_user.cd[*].arn)
}

output "cd_user_access_key_id" {
  value = one(aws_iam_access_key.cd[*].id)
}

output "cd_user_secret_access_key_id" {
  value     = one(aws_iam_access_key.cd[*].secret)
  sensitive = true
}
