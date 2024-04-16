# ###################################
# ##  LDAP Identity Provider  ###
# ###################################

# ## GET LDAP{ldap_url, bind_dn, bind_password} from VAULT
## Vault KV secret Example:
## {
##   "bind_dn": "<value>",
##   "bind_password": "<value>",
##   "ldap_url": "ldap://host.example.com?q=value",
##   "root_ca": "<value>"
## }

# data "vault_kv_secret_v2" "ldap_credentials" {
#   depends_on = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   mount      = var.ocp_vault_secret_engine_mount
#   name       = var.ldap_vault_secret_name
# }

# resource "rhcs_identity_provider" "ldap_idp" {
#   depends_on  = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   cluster     = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
#   name        = "MY-LDAP"
#   ldap = {
#     url        = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "ldap_url")
#     attributes = {
#       email = [ "mail" ]
#       id    = [ "dn" ]
#       name  = [ "cn" ]
#       preferred_username  =   [ "uid" ]
#     }
#     bind_dn = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "bind_dn")
#     bind_password = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "bind_password")
#     ca = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "root_ca")
#     insecure = false
#   }

# }