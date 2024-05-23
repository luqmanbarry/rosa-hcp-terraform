locals {
  acmhub_secret_name       = format("%s/%s", var.acmhub_vault_secret_path_prefix, var.acmhub_cluster_name)
  acmhub_api_url           = var.acmhub_pull_from_vault ? try(lookup(data.vault_kv_secret_v2.acmhub_credentials[0].data, "api_url"), null) : sensitive(var.acmhub_api_url)
  acmhub_username          = var.acmhub_pull_from_vault ? try(lookup(data.vault_kv_secret_v2.acmhub_credentials[0].data, "username"), null) : sensitive(var.acmhub_username)
  acmhub_password          = var.acmhub_pull_from_vault ? try(lookup(data.vault_kv_secret_v2.acmhub_credentials[0].data, "password"), null) : sensitive(var.acmhub_password)
  acmhub_kube_context      = var.acmhub_cluster_name
  
  managed_cluster_secret_name       = format("%s/%s/%s", var.business_unit, var.admin_creds_vault_secret_name_prefix, var.cluster_name)
  managed_cluster_api_url           = try(lookup(data.vault_kv_secret_v2.managed_cluster_credentials.data, "default_api_url"), null)
  managed_cluster_username          = try(lookup(data.vault_kv_secret_v2.managed_cluster_credentials.data, "username"), null)
  managed_cluster_password          = try(lookup(data.vault_kv_secret_v2.managed_cluster_credentials.data, "password"), null)
  managed_cluster_kube_context      = var.cluster_name
}
