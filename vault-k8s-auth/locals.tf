locals {
  # Should be route managed by custom IngressController
  custom_base_domain            = format("%s.%s.%s.%s", var.business_unit, var.cluster_name, var.openshift_environment, var.base_dns_domain)
  custom_ingress_domain         = format("%s.%s", var.custom_ingress_domain_prefix, local.custom_base_domain)
  backend_role_name             = format("%s/%s", var.business_unit, var.cluster_name)
  backend_path                  = format("%s/%s", var.vault_auth_backend_engine_path_prefix, var.openshift_environment)
  custom_backend_path           = format("%s/%s/%s", var.vault_auth_backend_engine_path_prefix, var.openshift_environment, local.backend_role_name)
  found_backend_paths           = data.vault_auth_backends.check_mount_paths.paths
  
  cluster_secret_name       = format("%s/%s/%s", var.business_unit, var.admin_creds_vault_secret_name_prefix, var.cluster_name)
  cluster_api_url           = try(lookup(data.vault_kv_secret_v2.managed_cluster_credentials.data, "default_api_url"), null)
}
