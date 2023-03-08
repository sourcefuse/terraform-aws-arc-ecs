locals {
  route_53_zone = trimprefix(var.acm_domain_name, "*.")
}
