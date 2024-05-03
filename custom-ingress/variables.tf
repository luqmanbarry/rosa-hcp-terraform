## AWS
variable "aws_region" {
  type    = string
  default = "us-east-2"
  description = "The region where the ROSA cluster is created"
}

variable "business_unit" {
  type        = string
  description = "The business that owns the cluster."
  default     = "sales"
}

variable "hosted_zone_id" {
  type = string
  description = "The hosted zone id"
  default = ""
}

variable "vault_token" {
  type = string
  default = ""
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

variable "vault_pki_path" {
  type = string
  default = "pki"
}

variable "vault_pki_ttl" {
  type = number
  default = 63070000 # 2 years in seconds
}

variable "base_dns_domain" {
    type = string
    default = "sales.corporate.com"
}

variable "ingress_sharding_tags" {
  type = list(string)
  description = "List of tags used to select the custom IngressController"
  default = [ "shard1" ]
}

variable "cluster_name" {
  default     = "rosa-sts-001"
  type        = string
  description = "The name of the ROSA cluster to create"
}

variable "openshift_environment" {
  type = string
  description = "The cluster environment"
  default = "dev"
}

variable "custom_ingress_name" {
  type = string
  description = "The name prefix of all custom ingress related resources"
  default = "shard1"
}

variable "custom_ingress_domain_prefix" {
  type = string
  default = "shard1.apps"
}

variable "ingress_pod_replicas" {
  type = number
  default = 3
}

variable "private_cluster" {
  type = bool
  default = true
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
  default = []
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
  default = []
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster-kube/config"
}

variable "ocp_vault_secret_engine_mount" {
  type = string
  description = "Vault KV engine mount path"
  default = "kv"
}

variable "admin_creds_vault_secret_name_prefix" {
  type = string
  default = "changeme"
}

variable "custom_ingress_machine_type" {
  type = string
  default = "m5.xlarge"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional AWS resource tags"
  default = {
    Terraform   = "true"
    Environment = "dev"
    Contact     = "lbarry@redhat.com"
  }
}

variable "default_mp_labels" {
  description       = "ROSA additional machine pool labels"
  type              = map(string)
  default = {}
}

variable "aws_additional_infra_security_group_ids" {
  description       = "AWS additional infra machines security groups"
  type              = list(string)
  default = [ ]
}

variable "custom_ingress_machine_pool_min_replicas" {
  type = number
  default = 1
}

variable "custom_ingress_machine_pool_max_replicas" {
  type = number
  default = 15
}

variable "ocm_token" {
  type        = string
  description = "The OCM API access token for your account"
  default = "your-ocm-token"
}

variable "ocm_url" {
  type        = string
  description = "Provide OCM environment by setting a value to url"
  default     = "https://api.openshift.com"
}

variable "ocp_version" {
  type        = string
  default     = "4.15.1"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}