###################################
##  GitHub Identity Provider  ###
###################################

## GET GitHub {client_id, client_secret, organizations} FROM VAULT
## Vault KV secret Example: Path /kv/identity-providers/<env>/github
## {
##   "client_id": "<value>",
##   "client_secret": "<value>",
##   "organizations": "[\"luqmanbarry\",\"amq-broker-cop\"]"
##   "teams": "[\"team-alpha\",\"team-delta\"]"
##   "hostname": "https://github.corporate.com"
## }

# data "vault_kv_secret_v2" "github_idp_credentials" {
#   depends_on = [ rhcs_cluster_wait.wait_for_cluster_build, rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
#   mount      = var.ocp_vault_secret_engine_mount
#   name       = var.github_idp_vault_secret_name
# }

# module "rosa-hcp_idp-github" {

#   source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
#   version = "1.6.1-prerelease.2"

#   depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]

#   cluster_id                  = data.rhcs_cluster_rosa_hcp.get_cluster.id
#   name                        = "GitHub"
#   idp_type                    = "github"
#   github_idp_client_id        = lookup(data.vault_kv_secret_v2.github_idp_credentials.data, "client_id")
#   github_idp_client_secret    = lookup(data.vault_kv_secret_v2.github_idp_credentials.data, "client_secret")
#   # github_idp_hostname      = lookup(data.vault_kv_secret_v2.github_idp_credentials.data, "github_hostname") # Toggle for self-hosted GitHub
#   github_idp_organizations    = lookup(data.vault_kv_secret_v2.github_idp_credentials.data, "organizations")
#   github_idp_teams            = lookup(data.vault_kv_secret_v2.github_idp_credentials.data, "teams")
#   github_idp_ca               = lookup(data.vault_kv_secret_v2.github_idp_credentials.data, "github_ca") # Toggle for self-hosted GitHub
  
# }