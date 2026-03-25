variable "cluster_id" {
  type        = string
  description = "ROSA cluster ID."
}

variable "openshift_version" {
  type        = string
  description = "OpenShift version for the machine pools."
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

variable "machine_pools" {
  type = list(object({
    name          = string
    instance_type = string
    subnet_id     = optional(string)
    labels        = optional(map(string), {})
    tags          = optional(map(string), {})
    autoscaling = optional(object({
      enabled      = bool
      min_replicas = number
      max_replicas = number
    }), null)
  }))
  description = "Additional machine pools."
  default     = []
}

