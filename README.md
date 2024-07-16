# terraform-aws-ecs-app
Terraform module to host an app on AWS ECS

Includes:

* VPC - Virtual Private Cloud
* ALB - Application Load Balancer
* ASG - Autoscaling Group
* ECS (Elastic Container Service) Cluster and Service
* ECR - Elastic Container Registry
* RDS (Relational Database Service) Instance
* CloudWatch Dashboard (optional)
* Cloudflare DNS Record (optional)
* Adminer database manager (optional)

## Inputs

- `health_check`

Defines health checks for load balancer target groups. See [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-health-checks.html) for details.

Example:

```hcl
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
```

- (TODO)

## Outputs

(TODO)


## Example

A working [example](https://github.com/silinternational/terraform-aws-ecs-app/tree/main/test) usage of this module is included in the source repository.

## More info

More information is available at the [Terraform Registry](https://registry.terraform.io/modules/silinternational/ecs-app/aws/latest)
