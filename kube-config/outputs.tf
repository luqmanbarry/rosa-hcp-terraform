# output "kubeconfig_file" {
#   depends_on = [ null_resource.set_acmhub_kubeconfig, null_resource.set_managed_cluster_kubeconfig ]
#   value = local_file.acmhub_kubeconfig_file.content
#   sensitive = true
# }