variable "ocm_token" {
  type        = string
  description = "The OCM API access token for your account"
}

variable "ocm_url" {
  type        = string
  description = "Provide OCM environment by setting a value to url"
  default     = "https://api.openshift.com"
}

variable "account_role_prefix" {
    type = string
    default = "ManagedOpenShift"
}

variable "openshift_environment" {
  type = string
  description = "The ROSA cluster environment"
  default = "dev"
}

variable "business_unit" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "create_account_roles" {
  default     = true
  type        = bool
  description = "Whether or not to create Account Roles"  
}

variable "ocp_version" {
  type        = string
  default     = "4.14.12"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster to create"
  default = "rosa-sts-001"
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

variable "single_nat_gateway" {
  type        = bool
  description = "Single NAT for all private subnets"
  default     = true
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

variable "base_dns_domain" {
  type = string
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