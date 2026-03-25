provider "aws" {
  region = var.aws_region
}

provider "rhcs" {
  token = var.ocm_token
  url   = var.ocm_url
}

locals {
  effective_replicas = var.autoscaling_enabled ? var.min_replicas : var.replicas
}

module "hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = var.rosa_hcp_module_version

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  aws_region             = var.aws_region
  aws_subnet_ids         = var.aws_subnet_ids
  aws_availability_zones = var.aws_availability_zones

  machine_cidr = var.machine_cidr
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr

  compute_machine_type = var.compute_machine_type
  replicas             = local.effective_replicas
  # The upstream module currently documents cluster-level autoscaler settings as unavailable.
  # Keep default worker sizing deterministic until ROSA HCP support is verified end-to-end.
  cluster_autoscaler_enabled = false
  autoscaler_max_nodes_total = null

  private                          = var.private_cluster
  default_ingress_listening_method = var.private_cluster ? "internal" : "external"

  create_account_roles  = var.create_account_roles
  create_oidc           = var.create_oidc
  create_operator_roles = var.create_operator_roles
  managed_oidc          = var.managed_oidc
  account_role_prefix   = coalesce(var.account_role_prefix, var.cluster_name)
  operator_role_prefix  = coalesce(var.operator_role_prefix, format("%s-HCP-ROSA", var.cluster_name))

  base_dns_domain                           = var.base_dns_domain
  aws_additional_compute_security_group_ids = var.aws_additional_compute_security_group_ids

  tags = merge(
    {
      cluster_name = var.cluster_name
      managed_by   = "terraform"
    },
    var.additional_tags
  )

  wait_for_create_complete = true
}
