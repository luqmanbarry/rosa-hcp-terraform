provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "selected" {
  tags = {
    cluster_name = var.network.vpc_lookup_tag
  }
}

data "aws_subnets" "selected" {
  tags = {
    cluster_name = var.network.vpc_lookup_tag
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_route_table" "subnets_route_tables" {
  for_each  = toset(data.aws_subnets.selected.ids)
  subnet_id = each.value
}

data "aws_subnet" "selected" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.value
}

data "aws_route53_zone" "selected" {
  name   = var.network.base_dns_domain
  vpc_id = data.aws_vpc.selected.id
}

locals {
  availability_zones = sort(distinct([
    for subnet in data.aws_subnet.selected : subnet.availability_zone
  ]))

  selected_availability_zones = var.multi_az ? local.availability_zones : slice(local.availability_zones, 0, min(length(local.availability_zones), 1))

  private_subnet_ids = sort([
    for rt in data.aws_route_table.subnets_route_tables :
    rt.subnet_id
    if length(trimspace(join("", rt.routes.*.gateway_id))) == 0
    && contains(local.selected_availability_zones, data.aws_subnet.selected[rt.subnet_id].availability_zone)
  ])

  public_subnet_ids = sort([
    for rt in data.aws_route_table.subnets_route_tables :
    rt.subnet_id
    if length(trimspace(join("", rt.routes.*.gateway_id))) > 0
    && contains(local.selected_availability_zones, data.aws_subnet.selected[rt.subnet_id].availability_zone)
  ])

  default_pool = var.machine_pools[0]
  default_machine_pool_profile = lookup(
    local.machine_pool_profile_map,
    local.default_pool.profile,
    local.machine_pool_profile_map.system,
  )
  additional_pool_defs = [
    for pool in slice(var.machine_pools, 1, length(var.machine_pools)) : {
      name = pool.name
      instance_type = coalesce(try(pool.instance_type, null), lookup(
        lookup(local.machine_pool_profile_map, pool.profile, local.machine_pool_profile_map.system),
        "instance_type",
        "m7i.xlarge",
      ))
      labels = merge(
        lookup(
          lookup(local.machine_pool_profile_map, pool.profile, local.machine_pool_profile_map.system),
          "labels",
          {},
        ),
        try(pool.labels, {}),
      )
      tags        = local.additional_tags
      autoscaling = pool.autoscaling
    }
  ]

  machine_pool_profile_map = {
    system = {
      instance_type = "m7i.xlarge"
      labels        = { "node-role.kubernetes.io/worker" = "" }
    }
    observability = {
      instance_type = "m7i.2xlarge"
      labels = {
        "node-role.kubernetes.io/infra"   = ""
        "workload.platform/observability" = "true"
      }
    }
    aap = {
      instance_type = "m7i.2xlarge"
      labels = {
        "workload.platform/aap" = "true"
      }
    }
    ai = {
      instance_type = "m7i.4xlarge"
      labels = {
        "workload.platform/ai" = "true"
      }
    }
  }

  additional_tags = {
    owner           = var.business_metadata.owner
    cost_center     = var.business_metadata.cost_center
    compliance_tier = var.business_metadata.compliance_tier
    environment     = var.environment
    cluster_class   = var.class_name
  }
}

module "rosa_hcp_core" {
  source = "../rosa-hcp-core"

  cluster_name                              = var.cluster_name
  openshift_version                         = var.openshift_version
  aws_region                                = var.aws_region
  ocm_token                                 = var.ocm_token
  ocm_url                                   = var.ocm_url
  private_cluster                           = var.private_cluster
  machine_cidr                              = data.aws_vpc.selected.cidr_block
  pod_cidr                                  = var.pod_cidr
  service_cidr                              = var.service_cidr
  aws_subnet_ids                            = var.private_cluster ? local.private_subnet_ids : concat(local.private_subnet_ids, local.public_subnet_ids)
  aws_availability_zones                    = local.selected_availability_zones
  compute_machine_type                      = lookup(local.default_machine_pool_profile, "instance_type", "m7i.xlarge")
  replicas                                  = local.default_pool.replicas
  autoscaling_enabled                       = local.default_pool.autoscaling.enabled
  min_replicas                              = local.default_pool.autoscaling.min_replicas
  max_replicas                              = local.default_pool.autoscaling.max_replicas
  base_dns_domain                           = data.aws_route53_zone.selected.name
  create_account_roles                      = var.create_account_roles
  create_oidc                               = var.create_oidc
  create_operator_roles                     = var.create_operator_roles
  managed_oidc                              = var.managed_oidc
  aws_additional_compute_security_group_ids = var.aws_additional_compute_security_group_ids
  additional_tags                           = local.additional_tags
}

module "rosa_hcp_machine_pools" {
  count  = length(local.additional_pool_defs) > 0 ? 1 : 0
  source = "../rosa-hcp-machine-pools"

  cluster_id        = module.rosa_hcp_core.cluster_id
  openshift_version = var.openshift_version
  aws_region        = var.aws_region
  ocm_token         = var.ocm_token
  ocm_url           = var.ocm_url
  machine_pools     = local.additional_pool_defs
}

module "acm_registration" {
  count  = var.enable_acm_registration && length(trimspace(var.managed_cluster_kubeconfig_filename)) > 0 && length(trimspace(var.acmhub_kubeconfig_filename)) > 0 ? 1 : 0
  source = "../rosa-hcp-acm-registration"

  cluster_name                        = var.cluster_name
  aws_region                          = var.aws_region
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  acmhub_kubeconfig_filename          = var.acmhub_kubeconfig_filename
  temp_dir                            = "${var.temp_dir}/acm/${var.cluster_name}"
}

module "workload_identity" {
  count  = var.workload_identity != null && var.workload_identity.enabled && length(var.workload_identity.roles) > 0 ? 1 : 0
  source = "../rosa-hcp-workload-identity"

  oidc_provider_arn = var.workload_identity.oidc_provider_arn
  oidc_provider_url = var.workload_identity.oidc_provider_url
  roles             = var.workload_identity.roles
  default_tags      = local.additional_tags
}

module "gitops_bootstrap" {
  count  = var.enable_gitops_bootstrap && length(trimspace(var.managed_cluster_kubeconfig_filename)) > 0 ? 1 : 0
  source = "../openshift-gitops-bootstrap"

  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  cluster_name                        = var.cluster_name
  gitops_git_repo_url                 = var.gitops.repository_url
  gitops_target_revision              = var.gitops.target_revision
  gitops_root_app_path                = try(var.gitops.root_app_path, "gitops/overlays/${var.gitops.overlay}")
  gitops_values                       = try(var.gitops.values, {})
  gitops_repo_username                = var.gitops_repo_username
  gitops_repo_password                = var.gitops_repo_password
}
