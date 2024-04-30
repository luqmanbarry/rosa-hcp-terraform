variable "business_unit" {
  type        = string
  description = "The business unit that owns the ROSA cluster."
}

variable "ocm_token" {
  type        = string
  description = "The OCM API access token for your account"
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


variable "ocp_version" {
  type        = string
  default     = "4.15.1"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

# ROSA Cluster info
variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster to create"
  default = "rosa-sts-001"
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

variable "path" {
  description = "(Optional) The arn path for the account/operator roles as well as their policies."
  type        = string
  default     = null
}

variable "machine_type" {
  description = "The AWS instance type used for your default worker pool"
  type        = string
  default     = "m5.xlarge"
}

variable "worker_node_replicas" {
  default     = 3
  description = "Number of worker nodes to provision. Single zone clusters need at least 2 nodes, multizone clusters need at least 3 nodes"
  type        = number
}


variable "autoscaling_enabled" {
  description = "Enables autoscaling. This variable requires you to set a maximum and minimum replicas range using the `max_replicas` and `min_replicas` variables."
  type        = string
  default     = "false"
}

variable "min_replicas" {
  description = "The minimum number of replicas for autoscaling."
  type        = number
  default     = 3
}

variable "max_replicas" {
  description = "The maximum number of replicas not exceeded by the autoscaling functionality."
  type        = number
  default     = 12
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
}

variable "pod_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Pods"
}

variable "service_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Services"
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

variable "vpc_id" {
  type = string
  default = "changeme"
}

variable "vpc_cidr_block" {
  type        = string
  description = "value of the CIDR block to use for the VPC"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
  description = "The region where the ROSA cluster is created"
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

variable "admin_creds_username" {
  type = string
  default = "changeme"
}

variable "admin_creds_password" {
  type = string
  default = "changeme"
}

variable "admin_creds_vault_generate" {
  type = bool
  default = true
}

variable "admin_creds_save_to_vault" {
  type = bool
  default = true
}

variable "ocp_vault_secret_engine_mount" {
  type = string
  description = "Vault KV engine mount path"
  default = "changeme"
}

variable "admin_creds_vault_secret_name_prefix" {
  type = string
  default = "changeme"
}

variable "hosted_zone_id" {
  type = string
  description = "Custom domain Route53 hosted zone id"
}

variable "vault_token" {
  type = string
  default = ""
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

variable "availability_zones" {
  description = "List of Availability Zones"
  type = list(string)
  default = [ ]
}

variable "ocm_environment" {
  type = string
  default = "production"
}

variable "openshift_environment" {
  type = string
  description = "The cluster environment"
  default = "dev"
}

variable "account_role_prefix" {
  type = string
  default = "ManagedOpenShift"
}

variable "base_dns_domain" {
  type = string
  description = "The custom ROSA cluster domain"
  default = "non-prod.sales.example.com"
}

variable "managed_oidc" {
  type          = bool
  default       = true
  description   = "Whether or not to deploy Managed or Unmanaged OIDC"
}

variable "use_static_oidc_configs" {
  type = bool
  default = true
  description = "Whether to use hardcoded OIDC config values or not."
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

variable "custom_ingress_domain_prefix" {
  type = string
  default = "shard1"
}

variable "default_mp_labels" {
  description       = "ROSA additional machine pool labels"
  type              = map(string)
}

variable "cicd_instance_cidr" {
  type = string
  default = "10.254.0.0/16"
}

variable "sg_inbound_from_port" {
  type = number
  default = 30000
}

variable "sg_inbound_to_port" {
  type = number
  default = 32900
}