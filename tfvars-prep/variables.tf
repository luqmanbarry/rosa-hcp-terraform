## AWS
variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "admin_creds_vault_secret_name_prefix" {
  type = string
  default = "rosa/cluster-admins/OCP_ENV"
}

variable "acmhub_cluster_name" {
  type = string
  default = "rosa-7wc76"
}

variable "acmhub_vault_secret_path_prefix" {
  type = string
  default = "acmhub/OCP_ENV"
}

variable "ocm_token_vault_path" {
  type = string
  default = "rosa/ocm-token"
}

variable "git_token_vault_path" {
  type = string
  default = "git/github/pat"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster"
  default = "rosa-sts-001"
}

variable "cost_center" {
  type        = string
  description = "Cost Center Identifier"
  default = "101010"
}

variable "ldap_vault_secret_name" {
  type = string
  default = "identity-providers/OCP_ENV/ldap"
}

variable "aad_vault_secret_name" {
  type = string
  default = "identity-providers/OCP_ENV/aad"
}

variable "github_idp_vault_secret_name" {
  type = string
  default = "identity-providers/OCP_ENV/github"
}

variable "gitlab_idp_vault_secret_name" {
  type = string
  default = "identity-providers/OCP_ENV/gitlab"
}

variable "ocp_version" {
  type        = string
  default     = "4.14.12"
  description = "Desird version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "machine_type" {
  type = string
  description = "The AWS instance type used for your default worker pool"
  default = "m5.xlarge"
}

variable "min_replicas" {
  type = number
  default = 3
  description = "The minmum number of worker nodes"
}

variable "max_replicas" {
  type = number
  default = 30
  description = "The maximum number of worker nodes"
}

variable "worker_node_replicas" {
  default     = 3
  description = "Number of worker nodes to provision. Single zone clusters need at least 2 nodes, multizone clusters need at least 3 nodes"
  type        = number
}

variable "autoscaling_enabled" {
  description = "Enables autoscaling. This variable requires you to set a maximum and minimum replicas range using the `max_replicas` and `min_replicas` variables."
  type        = bool
  default     = true
}

variable "ldap_name" {
  type = string
  description = "The name used by OpenShift OAuth"
  default = "MY-LDAP"
}

variable "ldap_pull_creds_from_vault" {
  type = bool
  default = true
}

variable "ldap_enable" {
  type = bool
  description = "Whether or not to enable LDAP as identity provider"
  default = true
}

variable "ldap_ca_configmap_name" {
  type = string
  default = "ldap-ca-config-map"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "rosa-sts-001"
}

variable "single_nat_gateway" {
  type = bool
  default = true
}

variable "vpc_cidr_block" {
  type        = string
  description = "value of the CIDR block to use for the VPC"
  default = "10.50.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "The CIDR blocks to use for the private subnets"
  default = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "The CIDR blocks to use for the public subnets"
  default = ["10.50.101.0/24", "10.50.102.0/24", "10.50.103.0/24"]
}

variable "additional_tags" {
  default = {
    Terraform   = "true"
    environment = "dev"
    contact     = "lbarry@redhat.com"
  }
  description = "Additional AWS resource tags"
  type        = map(string)
}

variable "tfstate_s3_bucket_name" {
  type = string
  default = "rosa-sts-tfstate"
}

variable "aws_account" {
  type        = string
  description = "The AWS account name or identifier"
  default = "012345678901"
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
  default = "https://github.com/"
}

variable "git_owner" {
  type = string
  description = "This is the target GitHub organization or individual user account to manage"
  default = "luqmanbarry"
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

variable openshift_environment {
  type = string
  description = "The ROSA cluster environment"
  default = "dev"
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

variable "create_account_roles" {
  default     = true
  type        = bool
  description = "Whether or not to create Account Roles"  
}

variable "path" {
  description = "(Optional) The arn path for the account/operator roles as well as their policies."
  type        = string
  default     = null
}

variable "proxy" {
  default     = null
  description = "cluster-wide HTTP or HTTPS proxy settings"
  type = object({
    enable                  = bool
    http_proxy              = string           # required  http proxy
    https_proxy             = string           # required  https proxy
    additional_trust_bundle = optional(string) # a string contains contains a PEM-encoded X.509 certificate bundle that will be added to the nodes' trusted certificate store.
    no_proxy                = optional(string) # no proxy
  })
}

variable "private_cluster" {
  type        = bool
  description = "Do you want this cluster to be private? true or false"
  default = false
}

variable "pod_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Pods"
  default = ""
}

variable "service_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Services"
  default = ""
}

variable "vpc_id" {
  type = string
  default = "changeme"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "VPC private subnets IDs for ROSA Cluster"
  default     = []
}

variable "public_subnet_ids" {
  type        = list(any)
  description = "VPC public subnets IDs for ROSA Cluster"
  default     = []
}

variable "admin_creds_vault_generate" {
  type = bool
  default = true
}

variable "ocp_vault_secret_engine_mount" {
  type = string
  description = "Vault KV engine mount path"
  default = "changeme"
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

variable "vault_login_path" {
  type = string
  default = "auth/approle/login"
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
  default = 63070000
}

variable "ocm_environment" {
  type = string
  default = "production"
}

variable "account_role_prefix" {
    type = string
    default = "ManagedOpenShift"
}

variable "managed_oidc" {
  type          = bool
  default       = true
  description   = "Whether or not to deploy Managed or Unmanaged OIDC"
}

variable "aws_additional_compute_security_group_ids" {
  description       = "AWS additional compute/worker machines security groups"
  type              = list(string)
  default = [  ]
}

variable "aws_additional_control_plane_security_group_ids" {
  description       = "AWS additional control plane machines security groups"
  type              = list(string)
  default = [  ]
}

variable "aws_additional_infra_security_group_ids" {
  description       = "AWS additional infra machines security groups"
  type              = list(string)
  default = [  ]
}

variable "default_mp_labels" {
  description       = "ROSA additional machine pool labels"
  type              = map(string)
  default = {}
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "acmhub_kubeconfig_filename" {
  type = string
  default = "~/.acmhub-kube/config"
}

variable "base_dns_domain" {
  type = string
  default = "non-prod.sales.corporate.com"
}

variable "ingress_sharding_tags" {
  type = list(string)
  description = "List of tags used to select the custom IngressController"
  default = [ "shard1" ]
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

variable "custom_ingress_machine_type" {
  type = string
  default = "m5.xlarge"
}

variable "custom_ingress_machine_pool_min_replicas" {
  type = number
  default = 1
}

variable "custom_ingress_machine_pool_max_replicas" {
  type = number
  default = 15
}

variable "admin_creds_vault_generate_secret" {
  type = bool
  default = true
}

variable "acmhub_username" {
  type = string
  default = "changeme"
}

variable "acmhub_password" {
  type = string
  default = "changeme"
}

variable "acmhub_pull_from_vault" {
  type = bool
  default = true
  description = "Whether to pull from Vault or not"
}

variable "acmhub_cluster_env" {
  type = string
  description = "ACMHUB Cluster Environment"
}

variable acmhub_api_server {
  type        = string
  description = "The ACMHUB api server hostname"
  default = ""
}

variable "vault_auth_backend_type" {
  type = string
  default = "kubernetes"
}

variable "vault_auth_backend_engine_path_prefix" {
  type = string
  default = "ocp/kubernetes"
  description = "The Vault path prefix to mount the auth backend"
}

variable "vault_auth_backend_kube_namespace" {
  type = string
  default = "changeme"
}

variable "vault_auth_backend_kube_sa" {
  type = string
  default = "changeme"
}

variable "vault_auth_backend_kube_sa_ttl" {
  type = string
  default = "8766h"
}

variable "vault_auth_backend_bound_sa_names" {
  type = list(string)
  default = []
}

variable "vault_auth_backend_bound_sa_namespaces" {
  type = list(string)
  default = []
}

variable "vault_auth_backend_token_policies" {
  type = list(string)
  default = []
}

variable "vault_auth_backend_audience" {
  type = string
  default = ""
}

variable "vault_auth_backend_token_ttl" {
  type = number
  default = 3600
}

variable "ocp_sg_inbound_from_port" {
  type = number
  default = 30000
}

variable "ocp_sg_inbound_to_port" {
  type = number
  default = 32900
}

variable "cicd_instance_cidr" {
  type = string
  default = "10.254.0.0/16"
}

variable "cicd_sg_inbound_from_port" {
  type = number
  default = 30000
}

variable "cicd_sg_inbound_to_port" {
  type = number
  default = 32900
}