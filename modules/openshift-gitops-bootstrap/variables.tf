variable "managed_cluster_kubeconfig_filename" {
  type        = string
  description = "Kubeconfig path for the managed cluster."
}

variable "cluster_name" {
  type        = string
  description = "Managed cluster name."
}

variable "gitops_operator_namespace" {
  type        = string
  description = "Namespace where the operator subscription is created."
  default     = "openshift-gitops-operator"
}

variable "gitops_namespace" {
  type        = string
  description = "Namespace for the Argo CD instance."
  default     = "openshift-gitops"
}

variable "gitops_channel" {
  type        = string
  description = "Operator channel."
  default     = "latest"
}

variable "gitops_git_repo_url" {
  type        = string
  description = "Git repository URL for the root application."
}

variable "gitops_target_revision" {
  type        = string
  description = "Git target revision for the root application."
  default     = "main"
}

variable "gitops_root_app_path" {
  type        = string
  description = "Path to the root app or overlay in the GitOps repository."
}

variable "gitops_values" {
  type        = any
  description = "Values object injected into the root app chart."
  default     = {}
}

variable "gitops_repo_username" {
  type        = string
  description = "Optional repository username."
  default     = ""
  sensitive   = true
}

variable "gitops_repo_password" {
  type        = string
  description = "Optional repository password or token."
  default     = ""
  sensitive   = true
}
