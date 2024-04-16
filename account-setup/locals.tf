locals {
  path = "/"
  split_arn = split("/", module.vpc.vpc_arn)
  vpc_id = element(local.split_arn, length(local.split_arn) - 1)
}