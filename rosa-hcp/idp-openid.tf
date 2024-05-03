# ###################################
# ##  OpenID Identity Provider  ###
# ###################################

# ## GET AAD{client_id, client_secret, issuer} FROM VAULT
## Vault KV secret Example: Path /kv/identity-providers/<env>/openid
## {
##   "client_id": "<value>",
##   "client_secret": "<value>",
##   "root_ca": "<value>",
##   "issuer": "https://login.microsoftonline.com/<GUID>"
## }

# data "vault_kv_secret_v2" "aad_credentials" {
#   depends_on = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   mount      = var.ocp_vault_secret_engine_mount
#   name       = var.aad_vault_secret_name
# }

# module "rosa-hcp_idp-openid" {

#   source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
#   version = "1.6.1-prerelease.2"

#   depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]

#   cluster_id                            = data.rhcs_cluster_rosa_hcp.get_cluster.id
#   name                                  = "Azure-AD"
#   idp_type                              = "openid"
#   openid_idp_client_id                  = lookup(data.vault_kv_secret_v2.aad_credentials.data, "client_id")
#   openid_idp_client_secret              = lookup(data.vault_kv_secret_v2.aad_credentials.data, "client_secret")
#   openid_idp_issuer                     = lookup(data.vault_kv_secret_v2.aad_credentials.data, "issuer")
#   openid_idp_ca                         = lookup(data.vault_kv_secret_v2.aad_credentials.data, "root_ca")
#   openid_idp_claims_email               = ["email"]
#   openid_idp_claims_preferred_username  = ["upn"]
# }