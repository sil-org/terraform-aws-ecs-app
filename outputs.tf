
output "app_url" {
  value = "https://${var.subdomain}.${var.domain_name}"
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.logs.name
}

output "database_host" {
  value = module.rds.address
}

output "database_password" {
  value     = random_password.db_root.result
  sensitive = true
}

output "ecr_repo_url" {
  value = module.ecr.repo_url
}
