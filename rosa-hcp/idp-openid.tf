# ###################################
# ##  OpenID Identity Provider  ###
# ###################################

# ## GET AAD{client_id, client_secret, issuer} FROM VAULT
## Vault KV secret Example:
## {
##   "client_id": "<value>",
##   "client_secret": "<value>",
##   "issuer": "https://login.microsoftonline.com/<GUID>"
## }

# data "vault_kv_secret_v2" "aad_credentials" {
#   depends_on = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   mount      = var.ocp_vault_secret_engine_mount
#   name       = var.aad_vault_secret_name
# }

# resource "rhcs_identity_provider" "openid_idp" {
#   depends_on  = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   cluster     = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
#   name        = "MY-AAD"
#   openid = {
#      client_id = lookup(data.vault_kv_secret_v2.aad_credentials.data, "client_id")
#      client_secret = lookup(data.vault_kv_secret_v2.aad_credentials.data, "client_secret")
#      issuer = lookup(data.vault_kv_secret_v2.aad_credentials.data, "issuer")
#      claims = {
#       email = ["email"]
#       preferred_username = ["upn"]

#      }
#   }
# }