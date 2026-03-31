variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the AWS IAM OIDC provider used by the ROSA cluster."
}

variable "oidc_provider_url" {
  type        = string
  description = "Issuer URL for the ROSA cluster OIDC provider."
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags applied to every IAM role."
  default     = {}
}

variable "roles" {
  type = list(object({
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
  description = "IAM roles that workloads can assume through service account tokens."
}
