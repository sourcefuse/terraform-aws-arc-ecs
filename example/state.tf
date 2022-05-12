terraform {
  required_version = "~> 1.1.9"

  backend "s3" {
    region         = "us-east-1"
    key            = "terraform-aws-ref-arch-ecs/terraform.tfstate"
    bucket         = "sf-ref-arch-terraform-state-dev"
    dynamodb_table = "sf_ref_arch_terraform_state_dev"
    encrypt        = true
  }
}
