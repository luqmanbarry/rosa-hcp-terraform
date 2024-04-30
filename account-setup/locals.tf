locals {
  path = "/"
  split_arn = split("/", module.vpc.vpc_arn)
  vpc_id = element(local.split_arn, length(local.split_arn) - 1)
  account_role_prefix = format("%s-ROSA-HCP", var.cluster_name)
  # account_role_prefix = "ManagedOpenShift"
}