# ###################################
# ##  LDAP Identity Provider  ###
# ###################################

# ## GET LDAP{ldap_url, bind_dn, bind_password} from VAULT
## Vault KV secret Example: Path /kv/identity-providers/<env>/ldap
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

# module "rosa-hcp_idp-ldap" {

#   source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
#   version = "1.6.1-prerelease.2"

#   depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]

#   cluster_id                        = data.rhcs_cluster_rosa_hcp.get_cluster.id
#   name                              = "LDAP"
#   idp_type                          = "ldap"
#   ldap_idp_url                      = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "ldap_url")
#   ldap_idp_bind_dn                  = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "bind_dn")
#   ldap_idp_bind_password            = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "bind_password")
#   ldap_idp_ca                       = lookup(data.vault_kv_secret_v2.ldap_credentials.data, "root_ca")
#   ldap_idp_insecure                 = false
#   ldap_idp_emails                   = ["mail"]
#   ldap_idp_ids                      = ["dn"]
#   ldap_idp_names                    = ["cn"]
#   ldap_idp_preferred_usernames      = ["uid"]
# }