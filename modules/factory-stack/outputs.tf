output "cluster_id" {
  value = module.rosa_hcp_core.cluster_id
}

output "api_url" {
  value = module.rosa_hcp_core.api_url
}

output "console_url" {
  value = module.rosa_hcp_core.console_url
}

output "cluster_domain" {
  value = module.rosa_hcp_core.cluster_domain
}

output "openshift_version" {
  value = module.rosa_hcp_core.current_version
}

output "workload_identity_role_arns" {
  value = length(module.workload_identity) > 0 ? module.workload_identity[0].role_arns : {}
}
