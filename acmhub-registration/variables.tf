variable "business_unit" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  default     = "rosa-sts-001"
  type        = string
  description = "The name of the ROSA cluster to create"
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster-kube/config"
}

variable "acmhub_kubeconfig_filename" {
  type = string
  default = "~/.acmhub-kube/config"
}

variable "openshift_environment" {
  type = string
  description = "The cluster environment"
  default = "dev"
}