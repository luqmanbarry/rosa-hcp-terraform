locals {
  tags_query = {
    cluster_name = local.cluster_name
  }

  # USER PROVIDED
  business_unit                                    = var.business_unit
  aws_account                                      = var.aws_account
  aws_region                                       = var.aws_region
  openshift_environment                            = var.openshift_environment
  cluster_name                                     = var.cluster_name
  cost_center                                      = var.cost_center
  ocp_version                                      = var.ocp_version
  acmhub_cluster_name                              = var.acmhub_cluster_name
  machine_type                                     = var.machine_type
  min_replicas                                     = var.min_replicas
  max_replicas                                     = var.max_replicas

  # CALCULATED VARS
  vpc_id                                           = data.aws_vpc.get_vpc.id
  vpc_cidr_block                                   = data.aws_vpc.get_vpc.cidr_block
  private_subnet_ids                               = sort(toset(data.aws_subnets.get_private_subnet_ids.ids))
  public_subnet_ids                                = sort(toset(data.aws_subnets.get_public_subnet_ids.ids))
  availability_zones                               = sort(toset([ for az in data.aws_subnet.get_availability_zones : az.availability_zone ]))
  hosted_zone_id                                   = data.aws_route53_zone.hosted_zone.id
  base_dns_domain                                  = data.aws_route53_zone.hosted_zone.name
  non_default_security_groups                      = sort(toset([ for sg in data.aws_security_group.aws_additional_security_groups : sg.id if strcontains(sg.name, "default") == false ]))
  aws_additional_compute_security_group_ids        = local.non_default_security_groups
  aws_additional_control_plane_security_group_ids  = local.non_default_security_groups
  aws_additional_infra_security_group_ids          = local.non_default_security_groups
  acmhub_cluster_env                               = local.openshift_environment
  # formatlist(aws_security_group.ocp_cluster_sg_config.id
  admin_creds_vault_secret_name_prefix             = replace(var.admin_creds_vault_secret_name_prefix, "OCP_ENV", local.openshift_environment)
  ldap_vault_secret_name                           = replace(var.ldap_vault_secret_name, "OCP_ENV", local.openshift_environment)
  github_idp_vault_secret_name                     = replace(var.github_idp_vault_secret_name, "OCP_ENV", local.openshift_environment)
  gitlab_idp_vault_secret_name                     = replace(var.gitlab_idp_vault_secret_name, "OCP_ENV", local.openshift_environment)
  aad_vault_secret_name                            = replace(var.aad_vault_secret_name, "OCP_ENV", local.openshift_environment)
  acmhub_vault_secret_path_prefix                  = replace(var.acmhub_vault_secret_path_prefix, "OCP_ENV", local.openshift_environment) # HYBRID
  git_token_vault_path                             = replace(var.git_token_vault_path, "OCP_ENV", local.openshift_environment)

  additional_tags                                  = {
    "business_unit"       = local.business_unit
    "cost_center"         = local.cost_center
    "deployer_role"       = "ManagedOpenShift-Installer-Role"
    "red-hat-clustertype" = "rosa"
    "team-maintainer"     = "platform-ops"
    
  }

  default_mp_labels = {
    "business_unit"       = local.business_unit
    "cost_center"         = local.cost_center
    "red-hat-clustertype" = "rosa"
    "team-maintainer"     = "platform-ops"
  }


  # TFVARs Paths
  admin_tfvars_path                                = format("${path.module}/../tfvars/admin/admin.tfvars")
  final_tfvars_path                                = format("${path.module}/../tfvars/%s/%s/%s.tfvars", local.business_unit, local.aws_account, local.cluster_name)
  
  # FINAL OUTPUT
  admin_tfvars_content                            = [
    "#========================= BEGIN: STATIC VARIABLES ===================================",
    file(local.admin_tfvars_path),
    "#========================= END: STATIC VARIABLES ====================================="
  ]

  dynamic_tfvars_content                           = [
      "#%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN: DYNAMIC VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",
      format("business_unit=%q", local.business_unit),
      format("aws_account=%q", local.aws_account),
      format("vpc_name=%q", var.cluster_name),
      format("vpc_id=%q", local.vpc_id),
      format("single_nat_gateway=%s", var.single_nat_gateway),
      format("aws_region=%q", local.aws_region),
      format("openshift_environment=%q", local.openshift_environment),
      format("cluster_name=%q", local.cluster_name),
      format("cost_center=%q", local.cost_center),
      format("ocp_version=%q", local.ocp_version),
      format("acmhub_cluster_name=%q", local.acmhub_cluster_name),
      format("machine_type=%q", local.machine_type),
      format("min_replicas=%s", local.min_replicas),
      format("max_replicas=%s", local.max_replicas),
      format("vpc_cidr_block=%q", local.vpc_cidr_block),
      format("private_subnet_cidrs=%v", toset(var.private_subnet_cidrs)),
      format("private_subnet_ids=%v", toset(local.private_subnet_ids)),
      format("public_subnet_cidrs=%v", toset(var.public_subnet_cidrs)),
      format("public_subnet_ids=%v", toset(local.public_subnet_ids)),
      format("availability_zones=%v", toset(local.availability_zones)),
      format("hosted_zone_id=%q", local.hosted_zone_id),
      format("base_dns_domain=%q", local.base_dns_domain),
      format("aws_additional_compute_security_group_ids=%v", local.aws_additional_compute_security_group_ids),
      format("aws_additional_control_plane_security_group_ids=%v", local.aws_additional_control_plane_security_group_ids),
      format("aws_additional_infra_security_group_ids=%v", toset(local.aws_additional_infra_security_group_ids)),
      format("acmhub_cluster_env=%q", local.acmhub_cluster_env),
      format("admin_creds_vault_secret_name_prefix=%q", local.admin_creds_vault_secret_name_prefix),
      format("ldap_vault_secret_name=%q", local.ldap_vault_secret_name),
      format("github_idp_vault_secret_name=%q", local.github_idp_vault_secret_name),
      format("gitlab_idp_vault_secret_name=%q", local.gitlab_idp_vault_secret_name),
      format("aad_vault_secret_name=%q", local.aad_vault_secret_name),
      format("acmhub_vault_secret_path_prefix=%q", local.acmhub_vault_secret_path_prefix),
      format("ocm_token_vault_path=%q", var.ocm_token_vault_path),
      format("ocm_url=%q", var.ocm_url),
      format("ocm_environment=%q", var.ocm_environment),
      format("git_token_vault_path=%q", local.git_token_vault_path),
      format("git_ci_job_number=%q", var.git_ci_job_number),
      format("git_ci_job_identifier=%q", var.git_ci_job_identifier),
      format("git_action_taken=%q", var.git_action_taken),
      replace(format("additional_tags=%v", local.additional_tags), ":", "="),
      replace(format("default_mp_labels=%v", local.default_mp_labels), ":", "="),
      "#%%%%%%%%%%%%%%%%%%%%%%%%% END: DYNAMIC VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    ]
  
  final_tfvars_content                             = join("\n\n",
    local.admin_tfvars_content, 
    local.dynamic_tfvars_content
  )

}
