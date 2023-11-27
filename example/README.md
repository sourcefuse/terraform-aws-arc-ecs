# Terraform Module: AWS ECS Example

## Overview

Example demonstrating how to use terraform-aws-refarch-ecs.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | sourcefuse/arc-ecs/aws | 1.3.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_domain_name"></a> [acm\_domain\_name](#input\_acm\_domain\_name) | Domain name the ACM Certificate belongs to | `string` | `"*.arc-poc.link"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | `"arc"` | no |
| <a name="input_private_subnet_names"></a> [private\_subnet\_names](#input\_private\_subnet\_names) | List of Private Subnet names in the VPC where the network resources currently exist.<br>If not defined, the default value from `terraform-aws-ref-arch-network` will be used.<br>From that module's example, the value is: [`example-dev-private-us-east-1a`, `example-dev-private-us-east-1b`] | `list(string)` | `[]` | no |
| <a name="input_public_subnet_names"></a> [public\_subnet\_names](#input\_public\_subnet\_names) | List of Public Subnet names in the VPC where the network resources currently exist.<br>If not defined, the default value from `terraform-aws-ref-arch-network` will be used.<br>From that module's example, the value is: [`example-dev-public-us-east-1a`, `example-dev-public-us-east-1b`] | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC where the network resources currently exist.<br>If not defined, the default value from `terraform-aws-ref-arch-network` will be used.<br>From that module's example, the name `example-dev-vpc` is used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the ECS Cluster |
| <a name="output_health_check_fqdn"></a> [health\_check\_fqdn](#output\_health\_check\_fqdn) | Health check FQDN record created in Route 53. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
