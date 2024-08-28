
variable "business_unit" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "vault_token" {
  type = string
  default = ""
}

variable "vault_login_approle_role_id" {
  type = string
  default = ""
}

variable "vault_login_approle_secret_id" {
  type = string
  default = ""
}

variable "vault_addr" {
  type = string
  default = ""
}

variable "cluster_name" {
  default     = "rosa-sts-001"
  type        = string
  description = "The name of the ROSA cluster to create"
}

variable "acmhub_cluster_name" {
  default     = ""
  type        = string
  description = "The name of the ACMHUB cluster"
}

variable "admin_creds_username" {
  type = string
  default = ""
}

variable "admin_creds_password" {
  type = string
  default = ""
}

variable "admin_creds_vault_secret_name_prefix" {
  type = string
  default = ""
}

variable "ocp_vault_secret_engine_mount" {
  type = string
  description = "Vault KV engine mount path"
  default = "kv"
}

variable "acmhub_username" {
  type = string
  default = ""
}

variable "acmhub_api_url" {
  type = string
  default = ""
}

variable "acmhub_password" {
  type = string
  default = ""
}

variable "acmhub_pull_from_vault" {
  type = bool
  default = true
  description = "Whether to pull from Vault or not"
}

variable "acmhub_vault_secret_path_prefix" {
  type = string
  default = ""
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "acmhub_kubeconfig_filename" {
  type = string
  default = "~/.acmhub_kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster_kube/config"
}