
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

resource "random_string" "random_name" {
  length           = 6
  special          = false
  upper            = false
}

resource "rhcs_cluster_rosa_hcp" "rosa_hcp_cluster" {
  depends_on           = [ time_sleep.wait_for_oidc ]

  name                 = local.cluster_name
  cloud_region         = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  aws_billing_account_id = data.aws_caller_identity.current.account_id
  availability_zones   = sort(toset(var.availability_zones))
  version              = var.ocp_version

  proxy                = (var.proxy.enable ? var.proxy : null)

  compute_machine_type = var.machine_type
  replicas             = local.worker_node_replicas
  
  sts                  = local.sts_roles

  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }

  ## Private link settings
  private          = var.private_cluster
  aws_subnet_ids   = var.private_cluster ? var.private_subnet_ids : concat(var.private_subnet_ids, var.public_subnet_ids)
  machine_cidr     = var.vpc_cidr_block
  pod_cidr         = var.pod_cidr
  service_cidr     = var.service_cidr

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z][-a-z0-9]{0,13}[a-z0-9]$", local.cluster_name))
      error_message = "ROSA cluster name must be less than 16 characters, be lower case alphanumeric, with only hyphens."
    }
  }

  tags                 = var.additional_tags
}

resource "rhcs_hcp_cluster_autoscaler" "enable_autoscaling" {
  depends_on = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
  cluster = local.cluster_name
  resource_limits = {
    max_nodes_total = var.autoscaling_enabled ? var.max_replicas : null
  }
}

resource "rhcs_cluster_wait" "wait_for_cluster_build" {
  cluster = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  # timeout in minutes
  timeout = 60
}