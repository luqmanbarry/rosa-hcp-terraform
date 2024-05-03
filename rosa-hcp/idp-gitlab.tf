###################################
##  GitLab Identity Provider  ###
###################################

## GET GitLab {client_id, client_secret, organizations} FROM VAULT
## Vault KV secret Example: Path /kv/identity-providers/<env>/gitlab
## {
##   "client_id": "<value>",
##   "client_secret": "<value>",
##   "gitlab_url": "https://gitlab.corporate.com/"
##   "gitlab_ca": "<value>"
## }

# data "vault_kv_secret_v2" "gitlab_idp_credentials" {
#   depends_on = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   mount      = var.ocp_vault_secret_engine_mount
#   name       = var.gitlab_idp_vault_secret_name
# }

# module "rosa-hcp_idp-gitlab" {

#   source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
#   version = "1.6.1-prerelease.2"

#   depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]

#   cluster_id               = data.rhcs_cluster_rosa_hcp.get_cluster.id
#   name                     = "GitLab"
#   idp_type                 = "gitlab"
#   gitlab_idp_client_id     = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "client_id")
#   gitlab_idp_client_secret = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "client_secret")
#   gitlab_idp_url           = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "gitlab_url")
#   gitlab_idp_ca            = lookup(data.vault_kv_secret_v2.gitlab_idp_credentials.data, "gitlab_ca")
  
# }