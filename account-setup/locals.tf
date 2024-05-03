locals {
  path = "/"
  vpc_id = module.rosa-hcp_vpc.vpc_id
  account_role_prefix = var.cluster_name
}