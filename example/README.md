# Terraform Module: AWS ECS Example

## Overview

Example demonstrating how to use terraform-aws-refarch-ecs.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.47.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | git::https://github.com/cloudposse/terraform-aws-acm-request-certificate | 0.17.0 |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | git@github.com:sourcefuse/terraform-aws-refarch-tags | 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_domain_name"></a> [acm\_domain\_name](#input\_acm\_domain\_name) | Domain name the ACM Certificate belongs to | `string` | `"*.arc-demo.io"` | no |
| <a name="input_acm_subject_alternative_names"></a> [acm\_subject\_alternative\_names](#input\_acm\_subject\_alternative\_names) | Subject alternative names for the ACM Certificate | `list(string)` | <pre>[<br>  "*.ecs-dev.arc-demo.io",<br>  "*.ecs-test.arc-demo.io"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"dev"` | no |
| <a name="input_health_check_route53_zone"></a> [health\_check\_route53\_zone](#input\_health\_check\_route53\_zone) | Route 53 zone for health check | `string` | n/a | yes |
| <a name="input_kms_admin_iam_role_identifier_arns"></a> [kms\_admin\_iam\_role\_identifier\_arns](#input\_kms\_admin\_iam\_role\_identifier\_arns) | IAM Role ARN to add to the KMS key for management | `list(string)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | `"arc"` | no |
| <a name="input_private_subnet_names"></a> [private\_subnet\_names](#input\_private\_subnet\_names) | List of private subnet names for the autoscaling group to launch instances in. | `list(string)` | `null` | no |
| <a name="input_public_subnet_names"></a> [public\_subnet\_names](#input\_public\_subnet\_names) | List of public subnet names for the ALB | `list(string)` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | List of VPC names to filter for | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
