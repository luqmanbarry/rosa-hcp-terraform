###################################
##  OpenID Identity Provider  ###
###################################

## GET GitLab {client_id, client_secret, organizations} FROM VAULT
## Vault KV secret Example:
## {
##   "client_id": "<value>",
##   "client_secret": "<value>",
##   "gitlab_url": "https://gitlab.corporate.com/"
## }

# data "vault_kv_secret_v2" "gitlab_idp_credentials" {
#   depends_on = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   mount      = var.ocp_vault_secret_engine_mount
#   name       = var.gitlab_idp_vault_secret_name
# }

# resource "rhcs_identity_provider" "gitlab_idp" {
#   depends_on  = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   cluster     = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
#   name        = "GitLab"
#   gitlab = {
#     client_id     = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "client_id")
#     client_secret = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "client_secret")
#     url           = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "gitlab_url")
#   }
# }