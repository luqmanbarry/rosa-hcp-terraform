variable "business_unit" {
  type        = string
  description = "The region where the ROSA cluster is created"
}

variable "vault_token" {
  type = string
  default = ""
}

variable "vpc_cidr_block" {
  type = string
}

variable "vault_auth_backend_type" {
  type = string
  default = "kubernetes"
}

variable "vault_auth_backend_engine_path_prefix" {
  type = string
  default = "kubernetes"
  description = "The Vault path prefix to mount the auth backend"
}

variable "vault_login_approle_role_id" {
  type = string
  default = "changeme"
}

variable "vault_login_approle_secret_id" {
  type = string
  default = "changeme"
}

variable "vault_addr" {
  type = string
  default = "changeme"
}

## VAULT AUTH BACKEND
variable "vault_auth_backend_kube_namespace" {
  type = string
  default = "changeme"
}

variable "vault_auth_backend_kube_sa" {
  type = string
  default = "changeme"
}

variable "vault_auth_backend_bound_sa_names" {
  type = list(string)
  default = []
}

variable "vault_auth_backend_bound_sa_namespaces" {
  type = list(string)
  default = []
}

variable "vault_auth_backend_token_policies" {
  type = list(string)
  default = []
}

variable "vault_auth_backend_audience" {
  type = string
  default = ""
}

variable "vault_auth_backend_token_ttl" {
  type = number
  default = 3600
}

variable "cluster_name" {
  default     = "rosa-sts-001"
  type        = string
  description = "The name of the ROSA cluster to create"
}

variable "custom_api_server_route_name" {
  type = string
  description = "The name of the additional route created for the API server"
  default = "api-server"
}

variable openshift_environment {
  type = string
  description = "The cluster environment"
}

variable "base_dns_domain" {
    type = string
    default = "ac.discoverfinancial.com"
}

variable "custom_ingress_domain_prefix" {
  type = string
  default = "shard1.apps"
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster-kube/config"
}

variable "admin_creds_vault_secret_name_prefix" {
  type = string
  default = ""
}

variable "ocp_vault_secret_engine_mount" {
  type = string
  description = "Vault KV engine mount path"
  default = "kvv2"
}