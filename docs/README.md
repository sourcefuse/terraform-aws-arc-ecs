# terraform-aws-ref-arch-ecs

Terraform AWS ECS module for the SourceFuse reference arch.

The module assumes that upstream dependencies, namely networking dependencies, are created upstream and the values are passed into this module via mechanisms such as Terraform data source queries.

![Module Components](./static/ecs_module_hla.png)

The module provisions

* ECS Cluster - we are focusing on the Fargate launch type, so we do not provision any underlying EC2 instances for the ECS launch type.
* Application Load Balancer
* Health Check Service - vanilla Nginx service that is used as the default route for the load balancer. The purpose of the health check service is to ensure that the core infrastructure, networking, security groups, etc. are configured correctly.
* Task execution IAM role - used by downstream services for task execution.
* Tags/SSM params - the module tags resources and outputs SSM params that can be used in data source lookups downstream for ECS services to reference to deploy into the cluster.

Our approach to ECS Fargate clusters is to provision a cluster and allow downstream services to attach to it via convention based data source queries.

## Usage

```hcl
module "terraform-aws-ref-arch-ecs" {
  source = "git::ssh://"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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

> This project was generated by [generator-tf-module](https://github.com/sudokar/generator-tf-module)

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
