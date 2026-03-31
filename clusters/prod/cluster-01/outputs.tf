output "cluster_id" {
  value = module.factory_stack.cluster_id
}

output "api_url" {
  value = module.factory_stack.api_url
}

output "console_url" {
  value = module.factory_stack.console_url
}

output "workload_identity_role_arns" {
  value = module.factory_stack.workload_identity_role_arns
}
