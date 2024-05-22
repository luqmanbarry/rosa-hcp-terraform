
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

resource "random_string" "random_name" {
  length           = 6
  special          = false
  upper            = false
}

module "rosa-hcp_rosa-cluster-hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/rosa-cluster-hcp"
  version = "1.6.1-prerelease.2"
  
  depends_on           = [ 
    time_sleep.wait_for_oidc,
    time_sleep.wait_for_operator_roles
  ]

  cluster_name                 = local.cluster_name
  aws_region                   = var.aws_region
  aws_account_id               = data.aws_caller_identity.current.account_id
  aws_billing_account_id       = data.aws_caller_identity.current.account_id # This may different in a prod environment
  aws_availability_zones       = toset(var.availability_zones)
  openshift_version            = var.ocp_version
  # PROXY
  http_proxy                   = (var.proxy.enable ? var.proxy.http_proxy : null)
  https_proxy                  = (var.proxy.enable ? var.proxy.https_proxy : null)
  no_proxy                     = (var.proxy.enable ? var.proxy.no_proxy : null)

  compute_machine_type         = var.machine_type
  cluster_autoscaler_enabled   = var.autoscaling_enabled
  replicas                     = var.autoscaling_enabled ? var.min_replicas : local.worker_node_replicas
  autoscaler_max_nodes_total   = var.autoscaling_enabled ? var.max_replicas : null

  ## Private link settings
  private                      = var.private_cluster
  aws_subnet_ids               = var.private_cluster ? var.private_subnet_ids : concat(var.private_subnet_ids, var.public_subnet_ids)
  machine_cidr                 = var.vpc_cidr_block
  pod_cidr                     = var.pod_cidr
  service_cidr                 = var.service_cidr

  ## STS SETTINGS
  installer_role_arn           = local.sts_roles.role_arn
  support_role_arn             = local.sts_roles.support_role_arn
  worker_role_arn              = local.sts_roles.instance_iam_roles.worker_role_arn
  oidc_config_id               = local.sts_roles.oidc_config_id
  operator_role_prefix         = local.sts_roles.operator_role_prefix
  wait_for_create_complete     = true

  tags = var.additional_tags

  # lifecycle {
  #   precondition {
  #     condition     = can(regex("^[a-z][-a-z0-9]{0,13}[a-z0-9]$", local.cluster_name))
  #     error_message = "ROSA cluster name must be less than 16 characters, be lower case alphanumeric, with only hyphens."
  #   }
  # }
}

# resource "rhcs_cluster_rosa_hcp" "rosa_hcp_cluster" {
#   depends_on           = [ 
#     time_sleep.wait_for_oidc,
#     time_sleep.wait_for_operator_roles
#   ]

#   name                 = local.cluster_name #done
#   cloud_region         = var.aws_region #done
#   aws_account_id       = data.aws_caller_identity.current.account_id #done
#   aws_billing_account_id = data.aws_caller_identity.current.account_id #done
#   availability_zones   = toset(var.availability_zones) #done
#   version              = var.ocp_version #done

#   proxy                = (var.proxy.enable ? var.proxy : null) #done

#   compute_machine_type = var.machine_type #done
#   replicas             = local.worker_node_replicas
  
#   sts                  = local.sts_roles

#   properties = {
#     rosa_creator_arn = data.aws_caller_identity.current.arn
#   }

#   ## Private link settings
#   private          = var.private_cluster
#   aws_subnet_ids   = var.private_cluster ? var.private_subnet_ids : concat(var.private_subnet_ids, var.public_subnet_ids)
#   machine_cidr     = var.vpc_cidr_block
#   pod_cidr         = var.pod_cidr
#   service_cidr     = var.service_cidr

#   lifecycle {
#     precondition {
#       condition     = can(regex("^[a-z][-a-z0-9]{0,13}[a-z0-9]$", local.cluster_name))
#       error_message = "ROSA cluster name must be less than 16 characters, be lower case alphanumeric, with only hyphens."
#     }
#   }

#   tags = var.additional_tags

#   wait_for_create_complete = true
#   # wait_for_std_compute_nodes_complete = true
# }

# resource "rhcs_hcp_cluster_autoscaler" "enable_autoscaling" {
#   depends_on  = [ data.rhcs_cluster_rosa_hcp.get_cluster ]

#   count = var.autoscaling_enabled ? 1 : 0

#   cluster     = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
#   resource_limits = {
#     max_nodes_total = var.max_replicas
#   }
# }