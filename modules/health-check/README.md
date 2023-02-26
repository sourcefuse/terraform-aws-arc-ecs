# Terraform Module: Health Check  

## Overview

AWS ALB Module Health Check

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener_rule.forward](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the ECS cluster. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster. | `string` | n/a | yes |
| <a name="input_health_check_path_pattern"></a> [health\_check\_path\_pattern](#input\_health\_check\_path\_pattern) | Path pattern to match against the request URL. | `string` | `"/"` | no |
| <a name="input_lb_listener_arn"></a> [lb\_listener\_arn](#input\_lb\_listener\_arn) | ARN of the load balancer listener. | `string` | n/a | yes |
| <a name="input_lb_security_group_ids"></a> [lb\_security\_group\_ids](#input\_lb\_security\_group\_ids) | LB Security Group IDs for ingress access to the health check task definition. | `list(string)` | n/a | yes |
| <a name="input_service_task_definition"></a> [service\_task\_definition](#input\_service\_task\_definition) | Family and revision (family:revision) or full ARN of the task definition that you want to run in your service. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to run health check task in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign the resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Id of the VPC where the resources will live | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_forward_listener_rule_arn"></a> [forward\_listener\_rule\_arn](#output\_forward\_listener\_rule\_arn) | TODO - add descriptions |
| <a name="output_forward_listener_rule_id"></a> [forward\_listener\_rule\_id](#output\_forward\_listener\_rule\_id) | n/a |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | n/a |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
