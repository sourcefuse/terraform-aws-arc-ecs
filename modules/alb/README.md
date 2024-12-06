# Terraform Module: ALB  

## Overview

AWS Terraform ALB Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.lb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb"></a> [alb](#input\_alb) | n/a | <pre>object({<br>    name                       = optional(string, null)<br>    port                       = optional(number)<br>    protocol                   = optional(string, "HTTP")<br>    internal                   = optional(bool, false)<br>    load_balancer_type         = optional(string, "application")<br>    idle_timeout               = optional(number, 60)<br>    enable_deletion_protection = optional(bool, false)<br>    enable_http2               = optional(bool, true)<br>    certificate_arn            = optional(string, null)<br><br>    access_logs = optional(object({<br>      bucket  = string<br>      enabled = optional(bool, false)<br>      prefix  = optional(string, "")<br>    }))<br><br>    tags = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_alb_target_group"></a> [alb\_target\_group](#input\_alb\_target\_group) | List of target groups to create | <pre>list(object({<br>    name                              = optional(string, "target-group")<br>    port                              = number<br>    protocol                          = optional(string, null)<br>    protocol_version                  = optional(string, "HTTP1")<br>    vpc_id                            = optional(string, "")<br>    target_type                       = optional(string, "instance")<br>    ip_address_type                   = optional(string, "ipv4")<br>    load_balancing_algorithm_type     = optional(string, "round_robin")<br>    load_balancing_cross_zone_enabled = optional(string, "use_load_balancer_configuration")<br>    deregistration_delay              = optional(number, 300)<br>    slow_start                        = optional(number, 0)<br>    tags                              = optional(map(string), {})<br><br>    health_check = optional(object({<br>      enabled             = optional(bool, true)<br>      protocol            = optional(string, "HTTP") # Allowed values: "HTTP", "HTTPS", "TCP", etc.<br>      path                = optional(string, "/")<br>      port                = optional(string, "traffic-port")<br>      timeout             = optional(number, 6)<br>      healthy_threshold   = optional(number, 3)<br>      unhealthy_threshold = optional(number, 3)<br>      interval            = optional(number, 30)<br>      matcher             = optional(string, "200") # Default HTTP matcher. Range 200 to 499<br>    }))<br><br>    stickiness = optional(object({<br>      enabled         = optional(bool, true)<br>      type            = string<br>      cookie_duration = optional(number, 86400)<br>      })<br>    )<br><br>  }))</pre> | n/a | yes |
| <a name="input_create_alb"></a> [create\_alb](#input\_create\_alb) | A flag that decides whether to create alb | `bool` | `false` | no |
| <a name="input_create_listener_rule"></a> [create\_listener\_rule](#input\_create\_listener\_rule) | n/a | `bool` | `false` | no |
| <a name="input_listener_rules"></a> [listener\_rules](#input\_listener\_rules) | List of listener rules to create | <pre>list(object({<br>    priority = number<br><br>    conditions = list(object({<br>      field  = string<br>      values = list(string)<br>    }))<br><br>    actions = list(object({<br>      type             = string<br>      target_group_arn = optional(string)<br>      order            = optional(number)<br>      redirect = optional(object({<br>        protocol    = string<br>        port        = string<br>        host        = optional(string)<br>        path        = optional(string)<br>        query       = optional(string)<br>        status_code = string<br>      }), null)<br><br>      fixed_response = optional(object({<br>        content_type = string<br>        message_body = optional(string)<br>        status_code  = optional(string)<br>      }), null)<br><br>    }))<br><br>  }))</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC in which security group for ALB has to be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | Use the filtered subnets |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)

### Configurations

- Configure pre-commit hooks
  ```sh
  pre-commit install
  ```

### Tests
- Tests are available in `test` directory
- Configure the dependencies
  ```sh
  cd test/
  go mod init github.com/sourcefuse/terraform-aws-refarch-alb
  go get github.com/gruntwork-io/terratest/modules/terraform
  ```
- Now execute the test  
  ```sh
  go test -timeout  30m
  ```

## Authors

This project is authored by:
- SourceFuse
