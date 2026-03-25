variable "rosa_hcp_module_version" {
  type        = string
  description = "Pinned version for the upstream ROSA HCP Terraform module."
  default     = "1.6.2"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name."
}

variable "openshift_version" {
  type        = string
  description = "OpenShift target minor or z-stream."
  default     = "4.20"
}

variable "aws_region" {
  type        = string
  description = "AWS region."
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

variable "private_cluster" {
  type        = bool
  description = "Whether the cluster is private."
  default     = true
}

variable "machine_cidr" {
  type        = string
  description = "Cluster machine CIDR."
}

variable "pod_cidr" {
  type        = string
  description = "Cluster pod CIDR."
  default     = "10.128.0.0/14"
}

variable "service_cidr" {
  type        = string
  description = "Cluster service CIDR."
  default     = "172.30.0.0/16"
}

variable "aws_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the cluster."
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "Availability zones for the cluster."
  default     = []
}

variable "compute_machine_type" {
  type        = string
  description = "Instance type for the default worker pool."
  default     = "m7i.xlarge"
}

variable "replicas" {
  type        = number
  description = "Worker count for the default pool when autoscaling is disabled."
  default     = 2
}

variable "autoscaling_enabled" {
  type        = bool
  description = "Whether the default worker pool uses autoscaling."
  default     = true
}

variable "min_replicas" {
  type        = number
  description = "Minimum replicas for the default worker pool."
  default     = 2
}

variable "max_replicas" {
  type        = number
  description = "Maximum replicas for the default worker pool."
  default     = 4
}

variable "base_dns_domain" {
  type        = string
  description = "Base DNS domain for custom domains where applicable."
  default     = null
}

variable "create_account_roles" {
  type        = bool
  description = "Whether to create account roles."
  default     = false
}

variable "create_oidc" {
  type        = bool
  description = "Whether to create OIDC resources."
  default     = true
}

variable "create_operator_roles" {
  type        = bool
  description = "Whether to create operator roles."
  default     = true
}

variable "managed_oidc" {
  type        = bool
  description = "Managed or unmanaged OIDC."
  default     = true
}

variable "account_role_prefix" {
  type        = string
  description = "Account role prefix."
  default     = null
}

variable "operator_role_prefix" {
  type        = string
  description = "Operator role prefix."
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to apply."
  default     = {}
}

variable "aws_additional_compute_security_group_ids" {
  type        = list(string)
  description = "Additional worker security groups."
  default     = []
}

