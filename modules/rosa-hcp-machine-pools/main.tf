provider "aws" {
  region = var.aws_region
}

provider "rhcs" {
  token = var.ocm_token
  url   = var.ocm_url
}

locals {
  machine_pools_by_name = {
    for pool in var.machine_pools : pool.name => pool
  }
}

module "machine_pool" {
  for_each = local.machine_pools_by_name

  source  = "terraform-redhat/rosa-hcp/rhcs//modules/machine-pool"
  version = "1.6.2"

  name              = each.value.name
  cluster_id        = var.cluster_id
  auto_repair       = true
  openshift_version = var.openshift_version
  subnet_id         = try(each.value.subnet_id, null)

  aws_node_pool = {
    instance_type = each.value.instance_type
    tags          = try(each.value.tags, {})
  }

  autoscaling = try(each.value.autoscaling, null)
  labels      = try(each.value.labels, {})
}

