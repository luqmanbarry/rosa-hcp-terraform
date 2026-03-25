variable "cluster_name" {
  type        = string
  description = "Cluster name as it should appear on the hub."
}

variable "aws_region" {
  type        = string
  description = "AWS region."
}

variable "managed_cluster_kubeconfig_filename" {
  type        = string
  description = "Kubeconfig path for the managed cluster."
}

variable "acmhub_kubeconfig_filename" {
  type        = string
  description = "Kubeconfig path for the ACM hub cluster."
}

variable "temp_dir" {
  type        = string
  description = "Directory for temporary ACM import files."
  default     = "/tmp/rosa-hcp-acm-registration"
}

