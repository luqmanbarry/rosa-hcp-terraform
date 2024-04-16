output "cluster_id" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
}

output "oidc_thumbprint" {
  value = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
}

output "oidc_endpoint_url" {
  value = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
}

output "api_url" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.api_url
}

output "console_url" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.console_url
}

output "domain" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.domain
}

# output "admin_username" {
#   value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.admin_credentials.username
#   sensitive = true
# }

# output "admin_password" {
#   value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.admin_credentials.password
#   sensitive = true
# }