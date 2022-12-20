vpc_name  = "refarchdevops-dev-vpc"
namespace = "arcdemo"
private_subnet_names = [
  "refarchdevops-dev-privatesubnet-private-us-east-1a",
  "refarchdevops-dev-privatesubnet-private-us-east-1b"
]
public_subnet_names = [
  "refarchdevops-dev-publicsubnet-public-us-east-1a",
  "refarchdevops-dev-publicsubnet-public-us-east-1b"
]
acm_domain_name               = "*.sfrefarch.com"
acm_subject_alternative_names = []
health_check_route53_zone     = "sfrefarch.com"
