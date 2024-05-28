variable "cluster_name" {
  default     = "rosa-sts-001"
  type        = string
  description = "The name of the ROSA cluster to create"
}

variable "aws_account" {
  type        = string
  description = "The AWS account name or identifier"
  default = "012345678901"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "business_unit" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "git_token" {
  type          = string
  description   = "The GitHub Personal Access Token (PAT)"
  default = "my-personal-access-token"
}

variable "git_base_url" {
  type          = string
  description   = "This is the target GitHub base API endpoint. The value must end with a slash."
  default = "https://corporate.github.com/"
}

variable "git_owner" {
  type = string
  description = "This is the target GitHub organization or individual user account to manage"
  default = "platform-ops"
}

variable "git_repository" {
  type = string
  description = "The GitHub Repository name"
  default = "rosa-sts-terraform"  
}

variable "git_base_branch" {
  type = string
  description = "The base branch" 
  default = "main" 
}

variable "git_ci_job_number" {
  type = string
  default = "123"
}

variable "git_ci_job_identifier" {
  type = string
  description = "The CI job identifier - Job url"
  default = "https://cicd.corporate.com/path/to/job/job-123"  
}

variable "git_commit_email" {
  type = string
  description = "The email of the commit author."
  default = "platform-ops@corporate.com"
}

variable "git_action_taken" {
  type            = string
  description     = "The action the CI Job took: options: ROSAClusterCreate, ROSAClusterUpdate,,,etc"
  default         = "ROSAClusterCreate"
}

variable "openshift_environment" {
  type = string
  description = "The ROSA cluster environment"
  default = "dev"
}