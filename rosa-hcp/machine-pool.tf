# module "rosa-hcp_machine-pool" {
#   source  = "terraform-redhat/rosa-hcp/rhcs//modules/machine-pool"
#   version = "1.6.1-prerelease.2"

#   count  = length(toset(var.private_subnet_ids))

#   depends_on = [ data.vault_kv_secret_v2.rosa_cluster_details ]
  
#   name                              = format("%s-%s", "custom-worker", count.index)
#   cluster_id                        = lookup(data.vault_kv_secret_v2.rosa_cluster_details.data, "cluster_id")
#   auto_repair                       = true
#   aws_node_pool                     = {
#     instance_type       = var.custom_ingress_machine_type
#     tags                = merge(var.additional_tags, var.default_mp_labels)
#   }
#   autoscaling                       = {
#     enabled = true
#     min_replicas                    = var.min_replicas
#     max_replicas                    = var.max_replicas
#   }
#   labels                            = merge(local.ingress_labels, var.additional_tags)
#   openshift_version                 = var.ocp_version
#   # subnet_id                         = (length(var.private_subnet_ids) > 2 ? null : one(var.private_subnet_ids) )
#   subnet_id                         = var.private_subnet_ids[count.index]
# }