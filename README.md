# terraform-aws-ref-arch-ecs

## Overview

Terraform Module for AWS ECS by the SourceFuse ARC team.

## Usage

```hcl
module "ecs" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-ecs"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ./modules/alb | n/a |
| <a name="module_cloudwatch_kms"></a> [cloudwatch\_kms](#module\_cloudwatch\_kms) | git::https://github.com/cloudposse/terraform-aws-kms-key | 0.12.1 |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | git@github.com:terraform-aws-modules/terraform-aws-ecs | v4.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_iam_policy_document.cloudwatch_loggroup_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_acm_certificate_arn"></a> [alb\_acm\_certificate\_arn](#input\_alb\_acm\_certificate\_arn) | ARN to the certificate that will be used on the ALB. | `string` | `""` | no |
| <a name="input_alb_idle_timeout"></a> [alb\_idle\_timeout](#input\_alb\_idle\_timeout) | The time that the connection is allowed to be idle. | `number` | `300` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Determines if this load balancer is internally or externally facing. | `bool` | `false` | no |
| <a name="input_alb_security_group_ids"></a> [alb\_security\_group\_ids](#input\_alb\_security\_group\_ids) | Security group Ids for access | `list(string)` | n/a | yes |
| <a name="input_alb_subnets_ids"></a> [alb\_subnets\_ids](#input\_alb\_subnets\_ids) | Subnet Ids assigned to the LB | `list(string)` | n/a | yes |
| <a name="input_alb_target_groups"></a> [alb\_target\_groups](#input\_alb\_target\_groups) | Target groups to add to the ALB | <pre>list(object({<br>    name         = string<br>    port         = number<br>    protocol     = string<br>    target_type  = string<br>    host_headers = list(string)<br>    path_pattern = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "host_headers": [<br>      "example.arc-demo.io"<br>    ],<br>    "name": "example",<br>    "path_pattern": [<br>      "/",<br>      "/*"<br>    ],<br>    "port": 443,<br>    "protocol": "HTTPS",<br>    "target_type": "ip"<br>  }<br>]</pre> | no |
| <a name="input_autoscaling_capacity_providers"></a> [autoscaling\_capacity\_providers](#input\_autoscaling\_capacity\_providers) | Map of autoscaling capacity provider definitions to create for the cluster | `any` | `{}` | no |
| <a name="input_autoscaling_subnet_names"></a> [autoscaling\_subnet\_names](#input\_autoscaling\_subnet\_names) | Names of the subnets to place the instances created by the autoscaling group. Recommended use is private subnets. | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_kms_key_name_override"></a> [cloudwatch\_kms\_key\_name\_override](#input\_cloudwatch\_kms\_key\_name\_override) | Cloudwatch. If null, the default will be `/aws/ecs/namespace-environment-ecs-fargate` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name_override"></a> [cloudwatch\_log\_group\_name\_override](#input\_cloudwatch\_log\_group\_name\_override) | Log group name override. If null, the default will be `/aws/ecs/namespace-environment-ecs-fargate` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_days"></a> [cloudwatch\_log\_group\_retention\_days](#input\_cloudwatch\_log\_group\_retention\_days) | Days to retain logs in the log group | `number` | `7` | no |
| <a name="input_cluster_image_id"></a> [cluster\_image\_id](#input\_cluster\_image\_id) | Image ID for the instances in the cluster | `string` | n/a | yes |
| <a name="input_cluster_instance_type"></a> [cluster\_instance\_type](#input\_cluster\_instance\_type) | Instance type for the | `string` | `"t3.medium"` | no |
| <a name="input_cluster_name_override"></a> [cluster\_name\_override](#input\_cluster\_name\_override) | Name to assign the cluster. If null, the default will be `namespace-environment-ecs-fargate` | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | n/a | yes |
| <a name="input_fargate_capacity_providers"></a> [fargate\_capacity\_providers](#input\_fargate\_capacity\_providers) | Map of Fargate capacity provider definitions to use for the cluster | `any` | `{}` | no |
| <a name="input_kms_admin_iam_role_identifier_arns"></a> [kms\_admin\_iam\_role\_identifier\_arns](#input\_kms\_admin\_iam\_role\_identifier\_arns) | IAM Role ARN to add to the KMS key for management | `list(string)` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign the resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Id of the VPC where the resources will live | `string` | n/a | yes |

## Outputs

No outputs.
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
cd test
go mod init github.com/sourcefuse/terraform-aws-ref-arch-db
go get github.com/gruntwork-io/terratest/modules/terraform
```
- Now execute the test
```sh
cd test/
go test
```

## Authors

This project is authored by:
- SourceFuse
