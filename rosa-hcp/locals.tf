locals {
  ldap_root_ca_keyname = "ca_crt"

  path = coalesce(var.path, "/")
  operator_role_prefix = format("%s-HCP-ROSA", local.cluster_name)
  account_role_prefix = var.cluster_name
  custom_dns_domain = format("apps.%s.%s.%s.%s", var.business_unit, var.cluster_name, var.openshift_environment, var.base_dns_domain)
  sts_roles = {
    role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-HCP-ROSA-Installer-Role",
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-HCP-ROSA-Support-Role",
    instance_iam_roles = {
      # master_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-ControlPlane-Role",
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-HCP-ROSA-Worker-Role"
    },
    operator_role_prefix = local.operator_role_prefix,
    oidc_config_id       = module.rosa-hcp_oidc-config-and-provider.oidc_config_id
  }

  worker_node_replicas  = var.autoscaling_enabled ? var.min_replicas : var.worker_node_replicas

  cluster_name = coalesce(var.cluster_name, "rosa-${random_string.random_name.result}")

  rosa_details_secret_name  = format("%s/%s/%s", var.business_unit, var.admin_creds_vault_secret_name_prefix, var.cluster_name)
  username = var.admin_creds_vault_generate ? random_uuid.username[0].result : var.admin_creds_username
  password = var.admin_creds_vault_generate ? random_password.password[0].result : var.admin_creds_password
  cluster_admin_idp = "cluster-admin"

  custom_base_domain                = format("apps.%s.%s.%s.%s", var.business_unit, var.cluster_name, var.openshift_environment, var.base_dns_domain)
  custom_ingress_domain             = format("%s.%s", var.custom_ingress_domain_prefix, local.custom_base_domain)  
}