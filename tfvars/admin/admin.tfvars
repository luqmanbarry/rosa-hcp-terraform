private_cluster               = false # Whether to deploy PrivateLink
#================ ACM HUB ==============================================================
acmhub_api_server       = ""
acmhub_username         = "" # Ignore if creds pulled form Vault
acmhub_password         = "" # Ignore if creds pulled form Vault
acmhub_pull_from_vault  = true
default_kubeconfig_filename         = "/Users/luqman/.kube/config" # Use absolute path
managed_cluster_kubeconfig_filename = "/Users/luqman/.managed_cluster-kube/config"
acmhub_kubeconfig_filename          = "/Users/luqman/.acmhub-kube/config" # Use absolute path 
#================ ROSA CLUSTER =========================================================
managed_oidc                  = true
worker_node_replicas          = 3
autoscaling_enabled           = true
custom_ingress_domain_prefix = "shard1"
custom_ingress_name          = "ingress-shard1"
custom_ingress_machine_type  = "m5.xlarge"
custom_ingress_machine_pool_min_replicas = 3
custom_ingress_machine_pool_max_replicas = 15
ingress_sharding_tags         = [ "shard1" ]
ingress_pod_replicas          = 3 # One pod per node. Must match number of available nodes (infra or worker or both)
admin_creds_vault_generate_secret     = true
ocp_vault_secret_engine_mount         = "kvv2"
pod_cidr                      = "172.128.0.0/14"
service_cidr                  = "172.127.0.0/16"

proxy           = {
  enable        = false
  http_proxy    = "http://proxy.corporate.com"
  https_proxy   = "http://proxy.corporate.com"
  no_proxy      = "ec2.us-east-1.amazonaws.com,.cluster.local,ec2.internal,.ec2.internal,s3.amazonaws.com"
}
#================ VAULT SECRETS/CERTS =============================================
vault_login_path                            = "auth/approle/login"
vault_login_approle_role_id                 = "changeme"
vault_addr                                  = "https://vault.apps.rosa-7wc76.2ecu.p1.openshiftapps.com"
vault_pki_path                              = "pki"
vault_pki_ttl                               = "63070000" # should be 2 years
#================ KUBERNETES VAULT AUTH BACKEND ===================================
vault_auth_backend_kube_namespace       = "default"
vault_auth_backend_type                 = "kubernetes"
vault_auth_backend_engine_path_prefix   = "kubernetes"
vault_auth_backend_kube_sa              = "vault-token-reviewer"
vault_auth_backend_bound_sa_names       = ["*"]
vault_auth_backend_bound_sa_namespaces  = ["*"]
vault_auth_backend_token_policies       = ["dev", "stg", "prod"]
vault_auth_backend_token_ttl            = 3600
vault_auth_backend_audience             = "vault"
#================= GIT MGMT OF TFVARS ================================================
git_base_url            = "https://github.com/"
git_owner               = "luqmanbarry"
git_repository          = "rosa-sts-terraform"
git_base_branch         = "main"
git_commit_email        = "dhabbhoufaamou@gmail.com"
#========================== CICD/Bastion Network Info ==============================
ocp_sg_inbound_from_port     = 30000
ocp_sg_inbound_to_port       = 32900
cicd_instance_cidr           = "10.254.0.0/16" # IP range of whereever automation scripts are running from
cicd_sg_inbound_from_port    = 30000
cicd_sg_inbound_to_port      = 32900
