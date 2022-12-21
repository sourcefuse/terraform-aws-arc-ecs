# Terraform Module: ALB  

## Overview

AWS ALB Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.30 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | git::https://github.com/cloudposse/terraform-aws-alb | 1.5.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_enabled"></a> [access\_logs\_enabled](#input\_access\_logs\_enabled) | A boolean flag to enable/disable access\_logs | `bool` | `true` | no |
| <a name="input_alb_access_logs_s3_bucket_force_destroy"></a> [alb\_access\_logs\_s3\_bucket\_force\_destroy](#input\_alb\_access\_logs\_s3\_bucket\_force\_destroy) | A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error | `bool` | `false` | no |
| <a name="input_alb_access_logs_s3_bucket_force_destroy_enabled"></a> [alb\_access\_logs\_s3\_bucket\_force\_destroy\_enabled](#input\_alb\_access\_logs\_s3\_bucket\_force\_destroy\_enabled) | When `true`, permits `force_destroy` to be set to `true`.<br>This is an extra safety precaution to reduce the chance that Terraform will destroy and recreate<br>your S3 bucket, causing COMPLETE LOSS OF ALL DATA even if it was stored in Glacier.<br>WARNING: Upgrading this module from a version prior to 0.27.0 to this version<br>  will cause Terraform to delete your existing S3 bucket CAUSING COMPLETE DATA LOSS<br>  unless you follow the upgrade instructions on the Wiki [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.27.0-(POTENTIAL-DATA-LOSS)).<br>  See additional instructions for upgrading from v0.27.0 to v0.28.0 [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.28.0-and-AWS-provider-v4-(POTENTIAL-DATA-LOSS)). | `bool` | `false` | no |
| <a name="input_cross_zone_load_balancing_enabled"></a> [cross\_zone\_load\_balancing\_enabled](#input\_cross\_zone\_load\_balancing\_enabled) | A boolean flag to enable/disable cross zone load balancing | `bool` | `true` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | A boolean flag to enable/disable deletion protection for ALB | `bool` | `false` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | The amount of time to wait in seconds before changing the state of a deregistering target to unused | `number` | `15` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment the resource belongs to | `string` | n/a | yes |
| <a name="input_http_ingress_cidr_blocks"></a> [http\_ingress\_cidr\_blocks](#input\_http\_ingress\_cidr\_blocks) | List of CIDR blocks to allow in HTTP security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_https_ingress_cidr_blocks"></a> [https\_ingress\_cidr\_blocks](#input\_https\_ingress\_cidr\_blocks) | List of CIDR blocks to allow in HTTPS security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Internal or external facing ALB. | `bool` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`. | `string` | `"ipv4"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to assign the resource | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace the resource belongs to | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group Ids for access | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet Ids assigned to the LB | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign the resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Id of the VPC where the resources will live | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN to the ALB |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | External DNS name to the ALB |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
