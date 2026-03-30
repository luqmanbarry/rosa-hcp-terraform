variable "cluster_name" {
  type        = string
  description = "Cluster name."
}

variable "class_name" {
  type        = string
  description = "Cluster class name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "openshift_version" {
  type        = string
  description = "OpenShift version."
  default     = "4.20"
}

variable "aws_region" {
  type        = string
  description = "AWS region."
}

variable "private_cluster" {
  type        = bool
  description = "Whether the cluster is private."
  default     = true
}

variable "multi_az" {
  type        = bool
  description = "Whether the cluster spans multiple AZs."
  default     = true
}

variable "business_metadata" {
  type = object({
    owner           = string
    cost_center     = string
    compliance_tier = string
  })
  description = "Business metadata for tags."
}

variable "network" {
  type = object({
    vpc_lookup_tag  = string
    base_dns_domain = string
  })
  description = "Network lookup inputs."
}

variable "acm" {
  type = object({
    hub_cluster_name = string
    labels           = map(string)
  })
  description = "ACM-related inputs."
  default     = null
}

variable "gitops" {
  type = object({
    overlay         = string
    repository_url  = string
    target_revision = string
    root_app_path   = optional(string)
    values          = optional(any)
  })
  description = "GitOps bootstrap inputs."
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
  description = "Machine pool definitions from the class/stack input."
}

variable "ocm_token" {
  type        = string
  description = "OCM offline token."
  sensitive   = true
}

variable "ocm_url" {
  type        = string
  description = "OCM API URL."
  default     = "https://api.openshift.com"
}

variable "create_account_roles" {
  type        = bool
  description = "Whether to create account roles."
  default     = false
}

variable "create_oidc" {
  type        = bool
  description = "Whether to create OIDC."
  default     = true
}

variable "create_operator_roles" {
  type        = bool
  description = "Whether to create operator roles."
  default     = true
}

variable "managed_oidc" {
  type        = bool
  description = "Whether to use managed OIDC."
  default     = true
}

variable "pod_cidr" {
  type        = string
  description = "Pod CIDR."
  default     = "10.128.0.0/14"
}

variable "service_cidr" {
  type        = string
  description = "Service CIDR."
  default     = "172.30.0.0/16"
}

variable "aws_additional_compute_security_group_ids" {
  type        = list(string)
  description = "Additional worker security groups."
  default     = []
}

variable "enable_acm_registration" {
  type        = bool
  description = "Whether to register the cluster to ACM."
  default     = false
}

variable "enable_gitops_bootstrap" {
  type        = bool
  description = "Whether to bootstrap OpenShift GitOps."
  default     = true
}

variable "managed_cluster_kubeconfig_filename" {
  type        = string
  description = "Kubeconfig path for the managed cluster."
  default     = ""
}

variable "acmhub_kubeconfig_filename" {
  type        = string
  description = "Kubeconfig path for the ACM hub cluster."
  default     = ""
}

variable "gitops_repo_username" {
  type        = string
  description = "Optional Git repository username."
  default     = ""
  sensitive   = true
}

variable "gitops_repo_password" {
  type        = string
  description = "Optional Git repository password or token."
  default     = ""
  sensitive   = true
}

variable "temp_dir" {
  type        = string
  description = "Temp directory used by ACM registration."
  default     = "/tmp/rosa-hcp-factory"
}
