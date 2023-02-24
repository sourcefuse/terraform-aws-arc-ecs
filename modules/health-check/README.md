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
| [aws_ecs_service.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener_rule.forward](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the ECS cluster. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster. | `string` | n/a | yes |
| <a name="input_health_check_host_headers"></a> [health\_check\_host\_headers](#input\_health\_check\_host\_headers) | A list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive.<br>Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character).<br>Only one pattern needs to match for the condition to be satisfied. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_health_check_path_patterns"></a> [health\_check\_path\_patterns](#input\_health\_check\_path\_patterns) | A list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters.<br>Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character).<br>Only one pattern needs to match for the condition to be satisfied. Path pattern is compared only to the path of the URL, not to<br>its query string. To compare against the query string, use a query\_string condition. | `list(string)` | <pre>[<br>  "/"<br>]</pre> | no |
| <a name="input_health_check_task_role_arn"></a> [health\_check\_task\_role\_arn](#input\_health\_check\_task\_role\_arn) | ARN of IAM role that allows the health check container task to make calls to other AWS services. | `string` | `null` | no |
| <a name="input_lb_listener_arn"></a> [lb\_listener\_arn](#input\_lb\_listener\_arn) | ARN of the load balancer listener. | `string` | n/a | yes |
| <a name="input_lb_security_group_ids"></a> [lb\_security\_group\_ids](#input\_lb\_security\_group\_ids) | LB Security Group IDs for ingress access to the health check task definition. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to run health check task in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign the resources. | `map(string)` | `{}` | no |
| <a name="input_task_definition_cpu"></a> [task\_definition\_cpu](#input\_task\_definition\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `1024` | no |
| <a name="input_task_definition_memory"></a> [task\_definition\_memory](#input\_task\_definition\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `2048` | no |
| <a name="input_task_definition_network_mode"></a> [task\_definition\_network\_mode](#input\_task\_definition\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `"awsvpc"` | no |
| <a name="input_task_definition_requires_compatibilities"></a> [task\_definition\_requires\_compatibilities](#input\_task\_definition\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Id of the VPC where the resources will live | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
