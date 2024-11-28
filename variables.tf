
/*
 * App configuration
 */

variable "app_env" {
  description = "The abbreviated version of the environment used for naming resources, typically either stg or prod"
  type        = string
}

variable "app_name" {
  description = "A name to be used, combined with \"app_env\", for naming resources. Should be unique in the AWS account."
  type        = string
}


/*
 * IAM configuration
 */

variable "create_cd_user" {
  description = "Set to true to create an IAM user with permissions for continuous deployment"
  default     = false
  type        = bool
}


/*
 * Cloudwatch configuration
 */

variable "create_dashboard" {
  description = "Set to false to skip creation of a CloudWatch dashboard"
  default     = true
  type        = bool
}

variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch application logs"
  default     = 30
  type        = number
}


/*
 * DNS configuration
 */

variable "create_dns_record" {
  description = "Set to false to skip creation of a Cloudflare DNS record"
  default     = true
  type        = bool
}

variable "dns_allow_overwrite" {
  description = "Controls whether this module can overwrite an existing DNS record with the same name. Can be used in a multiregion DNS-based failover configuration."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "The domain name on which to host the app. Combined with \"subdomain\" to create an ALB listener rule. Also used for the optional DNS record."
  type        = string
}

variable "subdomain" {
  description = "The subdomain on which to host the app. Combined with \"domain_name\" to create an ALB listener rule. Also used for the optional DNS record."
  type        = string
}


/*
 * ECS configuration
 */

variable "container_def_json" {
  description = "The ECS container task definition json"
  type        = string
}

variable "desired_count" {
  description = "The ECS service \"desired_count\" value"
  default     = 2
  type        = number
}


/*
 * ASG configuration
 */

variable "alarm_actions_enabled" {
  description = "Set to true to enable auto-scaling events and actions"
  default     = false
  type        = bool
}

variable "asg_min_size" {
  description = "The minimum size of the Autoscaling Group"
  default     = 1
  type        = number
}

variable "asg_max_size" {
  description = "The maximum size of the Autoscaling Group"
  default     = 5
  type        = number
}

variable "asg_tags" {
  description = "Tags to assign to the Autoscaling Group and EC2 instances"
  default     = {}
  type        = map(string)
}

variable "instance_type" {
  description = "See: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes"
  default     = "t2.micro"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of SSH key pair to use as default (ec2-user) user key. Set in the launch template"
  default     = ""
  type        = string
}


/*
 * VPC configuration
 */

variable "aws_zones" {
  description = "The VPC availability zone list"
  default     = ["us-east-1c", "us-east-1d", "us-east-1e"]
  type        = list(string)
}


/*
 * ALB configuration
 */

variable "default_cert_domain_name" {
  description = "Default/primary certificate domain name. Used to reference an existing certificate for use in the ALB"
  type        = string
}

variable "disable_public_ipv4" {
  description = "Set to true to remove the public IPv4 addresses from the ALB. Requires enable_ipv6 = true"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "Set to true to enable IPV6 in the ALB and VPC"
  type        = bool
  default     = false
}

variable "health_check" {
  description = "Elastic Load Balancer health check configuration"
  type        = map(string)
  default = {
    path    = "/"
    matcher = "200-399"
  }
}

/*
 * Database configuration
 */

variable "rds_ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  default     = null
  type        = string
}

variable "database_name" {
  description = "The name assigned to the created database"
  default     = "db"
  type        = string
}

variable "database_user" {
  description = "The name of the database root user"
  default     = "root"
  type        = string
}

variable "create_adminer" {
  description = "Set to true to create an Adminer database manager app instance"
  default     = false
  type        = bool
}

variable "enable_adminer" {
  description = "Set to true to create a DNS record and start the Adminer app. Requires create_adminer = true."
  default     = false
  type        = bool
}
