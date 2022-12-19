# Terraform Module: ECS Service  

## Overview

AWS ECS Service

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.30 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_definition"></a> [container\_definition](#module\_container\_definition) | ../ecs-container-definition | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.high_cpu_policy_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.high_memory_policy_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_task_role_policy"></a> [attach\_task\_role\_policy](#input\_attach\_task\_role\_policy) | Attach the task role policy to the task role | `bool` | `true` | no |
| <a name="input_autoscaling_cpu_threshold"></a> [autoscaling\_cpu\_threshold](#input\_autoscaling\_cpu\_threshold) | The desired threashold for CPU consumption | `number` | `75` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | The maximum number of tasks to provision | `number` | `3` | no |
| <a name="input_autoscaling_memory_threshold"></a> [autoscaling\_memory\_threshold](#input\_autoscaling\_memory\_threshold) | The desired threashold for memory consumption | `number` | `75` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | The minimum number of tasks to provision | `number` | `1` | no |
| <a name="input_container_definition_defaults"></a> [container\_definition\_defaults](#input\_container\_definition\_defaults) | Default values to use on all container definitions created if a specific value is not specified | `any` | `{}` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Map of maps that define container definitions to create | `any` | `{}` | no |
| <a name="input_cp_strategy_base"></a> [cp\_strategy\_base](#input\_cp\_strategy\_base) | Base number of tasks to create on Fargate on-demand | `number` | `1` | no |
| <a name="input_cp_strategy_fg_spot_weight"></a> [cp\_strategy\_fg\_spot\_weight](#input\_cp\_strategy\_fg\_spot\_weight) | Relative number of tasks to put in Fargate Spot | `number` | `0` | no |
| <a name="input_cp_strategy_fg_weight"></a> [cp\_strategy\_fg\_weight](#input\_cp\_strategy\_fg\_weight) | Relative number of tasks to put in Fargate | `number` | `1` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units used by the task. | `number` | `256` | no |
| <a name="input_deployment_controller"></a> [deployment\_controller](#input\_deployment\_controller) | Specifies which deployment controller to use for the service. | `string` | `"ECS"` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Maximum percentage of task able to be deployed | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The minimum number of tasks, specified as a percentage of the Amazon ECS service's DesiredCount value, that must continue to run and remain healthy during a deployment. | `number` | `100` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The desired number of instantiations of the task definition to keep running on the service. | `number` | `1` | no |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | The ECS cluster ID in which the resources will be created | `string` | n/a | yes |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Determines whether autoscaling is enabled for the service | `bool` | `false` | no |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Specifies whether to enable Amazon ECS managed tags for the tasks within the service. | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service. | `bool` | `false` | no |
| <a name="input_enable_scheduled_autoscaling"></a> [enable\_scheduled\_autoscaling](#input\_enable\_scheduled\_autoscaling) | Determines whether scheduled autoscaling is enabled for the service | `bool` | `false` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ecs-blueprint-infra ECS execution ARN | `string` | n/a | yes |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Number of seconds for the task health check | `number` | `30` | no |
| <a name="input_lb_container_name"></a> [lb\_container\_name](#input\_lb\_container\_name) | The container name for the LB | `string` | `null` | no |
| <a name="input_lb_container_port"></a> [lb\_container\_port](#input\_lb\_container\_port) | The port that the container will use to listen to requests | `number` | `null` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A list of load balancer config objects for the ECS service | <pre>list(object({<br>    target_group_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The number of cpu units used by the task. | `number` | `1024` | no |
| <a name="input_name"></a> [name](#input\_name) | The name for the ecs service | `string` | n/a | yes |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | The OS family for task | `string` | `"LINUX"` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | Platform version on which to run your service | `string` | `null` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION. | `string` | `"SERVICE"` | no |
| <a name="input_scheduled_autoscaling_down_max_capacity"></a> [scheduled\_autoscaling\_down\_max\_capacity](#input\_scheduled\_autoscaling\_down\_max\_capacity) | The maximum number of tasks to provision | `number` | `3` | no |
| <a name="input_scheduled_autoscaling_down_min_capacity"></a> [scheduled\_autoscaling\_down\_min\_capacity](#input\_scheduled\_autoscaling\_down\_min\_capacity) | The minimum number of tasks to provision | `number` | `1` | no |
| <a name="input_scheduled_autoscaling_down_time"></a> [scheduled\_autoscaling\_down\_time](#input\_scheduled\_autoscaling\_down\_time) | Timezone which scheduled scaling occurs | `string` | `"cron(0 20 * * ? *)"` | no |
| <a name="input_scheduled_autoscaling_timezone"></a> [scheduled\_autoscaling\_timezone](#input\_scheduled\_autoscaling\_timezone) | Timezone which scheduled scaling occurs | `string` | `"America/Los_Angeles"` | no |
| <a name="input_scheduled_autoscaling_up_max_capacity"></a> [scheduled\_autoscaling\_up\_max\_capacity](#input\_scheduled\_autoscaling\_up\_max\_capacity) | The maximum number of tasks to provision | `number` | `6` | no |
| <a name="input_scheduled_autoscaling_up_min_capacity"></a> [scheduled\_autoscaling\_up\_min\_capacity](#input\_scheduled\_autoscaling\_up\_min\_capacity) | The minimum number of tasks to provision | `number` | `4` | no |
| <a name="input_scheduled_autoscaling_up_time"></a> [scheduled\_autoscaling\_up\_time](#input\_scheduled\_autoscaling\_up\_time) | Timezone which scheduled scaling occurs | `string` | `"cron(0 6 * * ? *)"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. | `list(string)` | n/a | yes |
| <a name="input_service_registry_list"></a> [service\_registry\_list](#input\_service\_registry\_list) | A list of service discovery registry names for the service | <pre>list(object({<br>    registry_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets associated with the task or service. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags | `map(string)` | `{}` | no |
| <a name="input_task_cpu_architecture"></a> [task\_cpu\_architecture](#input\_task\_cpu\_architecture) | CPU architecture X86\_64 or ARM64 | `string` | `"X86_64"` | no |
| <a name="input_task_role_policy"></a> [task\_role\_policy](#input\_task\_role\_policy) | The task's role policy | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->