variable "cluster_name" {
  type = string
}

variable "class_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "openshift_version" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "private_cluster" {
  type = bool
}

variable "multi_az" {
  type = bool
}

variable "business_metadata" {
  type = object({
    owner           = string
    cost_center     = string
    compliance_tier = string
  })
}

variable "network" {
  type = object({
    vpc_lookup_tag  = string
    base_dns_domain = string
  })
}

variable "acm" {
  type = object({
    hub_cluster_name = string
    labels           = map(string)
  })
  default = null
}

variable "gitops" {
  type = object({
    overlay         = string
    repository_url  = string
    target_revision = string
    root_app_path   = optional(string)
    values          = optional(any)
  })
}

variable "workload_identity" {
  type = object({
    enabled           = bool
    oidc_provider_arn = string
    oidc_provider_url = string
    roles = list(object({
      name                 = string
      namespace            = string
      service_account_name = string
      description          = optional(string)
      managed_policy_arns  = optional(list(string), [])
      inline_policy_json   = optional(string, "")
      max_session_duration = optional(number, 3600)
      path                 = optional(string, "/")
      tags                 = optional(map(string), {})
    }))
  })
  default = null
}

variable "machine_pools" {
  type = list(object({
    name          = string
    profile       = string
    replicas      = number
    instance_type = optional(string)
    labels        = optional(map(string), {})
    autoscaling = object({
      enabled      = bool
      min_replicas = number
      max_replicas = number
    })
  }))
}

variable "enable_acm_registration" {
  type = bool
}

variable "enable_gitops_bootstrap" {
  type = bool
}

variable "ocm_token" {
  type      = string
  sensitive = true
}

variable "ocm_url" {
  type    = string
  default = "https://api.openshift.com"
}

variable "create_account_roles" {
  type    = bool
  default = false
}

variable "create_oidc" {
  type    = bool
  default = true
}

variable "create_operator_roles" {
  type    = bool
  default = true
}

variable "managed_oidc" {
  type    = bool
  default = true
}

variable "pod_cidr" {
  type    = string
  default = "10.128.0.0/14"
}

variable "service_cidr" {
  type    = string
  default = "172.30.0.0/16"
}

variable "aws_additional_compute_security_group_ids" {
  type    = list(string)
  default = []
}

variable "managed_cluster_kubeconfig_filename" {
  type    = string
  default = ""
}

variable "acmhub_kubeconfig_filename" {
  type    = string
  default = ""
}

variable "gitops_repo_username" {
  type      = string
  default   = ""
  sensitive = true
}

variable "gitops_repo_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "temp_dir" {
  type    = string
  default = "/tmp/rosa-hcp-factory"
}
