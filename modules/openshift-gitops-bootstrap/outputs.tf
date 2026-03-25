output "gitops_namespace" {
  value = var.gitops_namespace
}

output "root_application_name" {
  value = format("%s-root", var.cluster_name)
}

