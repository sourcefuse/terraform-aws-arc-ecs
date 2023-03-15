# Terraform Module: Health Check  

## Overview

AWS Terraform ALB Health Check Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_health_check_container_definition"></a> [health\_check\_container\_definition](#module\_health\_check\_container\_definition) | git::https://github.com/aws-ia/ecs-blueprints.git//modules/ecs-container-definition | 5a80841ac6f2436941c45e7a9cd9b69407b9ab32 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener_rule.forward](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_dns_name"></a> [alb\_dns\_name](#input\_alb\_dns\_name) | ALB DNS name to create A record for health check service | `string` | n/a | yes |
| <a name="input_alb_zone_id"></a> [alb\_zone\_id](#input\_alb\_zone\_id) | ALB Route53 zone ID to create A record for health check service | `string` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the ECS cluster. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster. | `string` | n/a | yes |
| <a name="input_health_check_desired_count"></a> [health\_check\_desired\_count](#input\_health\_check\_desired\_count) | Number of ECS tasks to run for the health check. | `number` | `1` | no |
| <a name="input_health_check_image"></a> [health\_check\_image](#input\_health\_check\_image) | Docker image used for the health-check | `string` | `"ealen/echo-server"` | no |
| <a name="input_health_check_launch_type"></a> [health\_check\_launch\_type](#input\_health\_check\_launch\_type) | Launch type for the health check service. | `string` | `"FARGATE"` | no |
| <a name="input_health_check_path_pattern"></a> [health\_check\_path\_pattern](#input\_health\_check\_path\_pattern) | Path pattern to match against the request URL. | `string` | `"/"` | no |
| <a name="input_health_check_route_53_record_type"></a> [health\_check\_route\_53\_record\_type](#input\_health\_check\_route\_53\_record\_type) | Health check Route53 record type | `string` | `"A"` | no |
| <a name="input_health_check_route_53_records"></a> [health\_check\_route\_53\_records](#input\_health\_check\_route\_53\_records) | List of A record domains to create for the health check service | `list(string)` | n/a | yes |
| <a name="input_health_check_service_registry_list"></a> [health\_check\_service\_registry\_list](#input\_health\_check\_service\_registry\_list) | A list of service discovery registry names for the service | <pre>list(object({<br>    registry_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_lb_listener_arn"></a> [lb\_listener\_arn](#input\_lb\_listener\_arn) | ARN of the load balancer listener. | `string` | n/a | yes |
| <a name="input_lb_security_group_ids"></a> [lb\_security\_group\_ids](#input\_lb\_security\_group\_ids) | LB Security Group IDs for ingress access to the health check task definition. | `list(string)` | n/a | yes |
| <a name="input_route_53_private_zone"></a> [route\_53\_private\_zone](#input\_route\_53\_private\_zone) | Used with `name` field to get a private Hosted Zone | `bool` | `false` | no |
| <a name="input_route_53_zone_name"></a> [route\_53\_zone\_name](#input\_route\_53\_zone\_name) | Route53 zone name used for looking up and creating an `A` record for the health check service | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to run health check task in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign the resources. | `map(string)` | `{}` | no |
| <a name="input_task_definition_cpu"></a> [task\_definition\_cpu](#input\_task\_definition\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `1024` | no |
| <a name="input_task_definition_memory"></a> [task\_definition\_memory](#input\_task\_definition\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `2048` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Id of the VPC where the resources will live | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_forward_listener_rule_arn"></a> [forward\_listener\_rule\_arn](#output\_forward\_listener\_rule\_arn) | TODO - add descriptions |
| <a name="output_forward_listener_rule_id"></a> [forward\_listener\_rule\_id](#output\_forward\_listener\_rule\_id) | n/a |
| <a name="output_route_53_fqdn"></a> [route\_53\_fqdn](#output\_route\_53\_fqdn) | Health check FQDN record created in Route 53. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | n/a |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | n/a |
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
  go mod init github.com/sourcefuse/terraform-aws-refarch-health-check
  go get github.com/gruntwork-io/terratest/modules/terraform
  ```
- Now execute the test  
  ```sh
  go test -timeout  30m
  ```

## Authors

This project is authored by:
- SourceFuse
