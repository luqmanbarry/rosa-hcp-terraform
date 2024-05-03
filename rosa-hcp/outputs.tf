output "cluster_id" {
  # value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  value = module.rosa-hcp_rosa-cluster-hcp.cluster_id
}


output "oidc_endpoint_url" {
  value = module.rosa-hcp_oidc-config-and-provider.oidc_endpoint_url
}

output "api_url" {
  value = data.rhcs_cluster_rosa_hcp.get_cluster.api_url
}

output "console_url" {
  value = data.rhcs_cluster_rosa_hcp.get_cluster.console_url
}

output "domain" {
  value = data.rhcs_cluster_rosa_hcp.get_cluster.domain
}

output "admin_username" {
  value = local.username
  sensitive = true
}

output "admin_password" {
  value = local.password
  sensitive = true
}