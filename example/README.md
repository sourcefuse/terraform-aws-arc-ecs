# terraform-aws-ref-arch-ecs Example

## Overview

Example demonstrating how to use terraform-aws-ref-arch-ecs


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_fargate"></a> [ecs\_fargate](#module\_ecs\_fargate) | ../. | n/a |
| <a name="module_ecs_service_fargate"></a> [ecs\_service\_fargate](#module\_ecs\_service\_fargate) | ../health-check-service | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_tls_cert_arn"></a> [alb\_tls\_cert\_arn](#input\_alb\_tls\_cert\_arn) | n/a | `any` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | n/a | `any` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | n/a | `any` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | n/a | `any` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | n/a | `any` | n/a | yes |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | n/a | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `""` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"default_value"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_service_desired_count"></a> [service\_desired\_count](#input\_service\_desired\_count) | n/a | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs | `list` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `any` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb"></a> [alb](#output\_alb) | n/a |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | n/a |
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


- Configure golang deps for tests
```sh
> go get github.com/gruntwork-io/terratest/modules/terraform
> go get github.com/stretchr/testify/assert
```



### Tests

- Tests are available in `test` directory

- In the test directory, run the below command
```sh
go test
```



## Authors

This project is authored by below people

- SourceFuse

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_tls_cert_arn"></a> [alb\_tls\_cert\_arn](#input\_alb\_tls\_cert\_arn) | The ARN of the certificate that the ALB uses for https | `any` | n/a | yes |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | Alias record created for LB | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | the name of your environment, e.g. "prod" | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | the name of your stack, e.g. "demo" | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The aws region | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `any` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 zone for alias record | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb"></a> [alb](#output\_alb) | n/a |
| <a name="output_aws_ecr_repository_url"></a> [aws\_ecr\_repository\_url](#output\_aws\_ecr\_repository\_url) | n/a |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | n/a |
| <a name="output_ecs_target_group_arn"></a> [ecs\_target\_group\_arn](#output\_ecs\_target\_group\_arn) | n/a |
<!-- END_TF_DOCS -->
