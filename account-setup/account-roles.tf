data "rhcs_versions" "all" {
  count = var.create_account_roles ? 1 : 0
}

data "rhcs_hcp_policies" "all_policies" {}

module "create_account_roles" {
  
  count = var.create_account_roles ? 1 : 0

  source  = "terraform-redhat/rosa-sts/aws"
  version = "0.0.15"
 
  # source  = "terraform-redhat/terraform-rhcs-rosa-hcp"
  # version = "v1.5.0"

  create_account_roles  = var.create_account_roles
  create_operator_roles = false

  account_role_prefix    = var.account_role_prefix
  path                   = local.path
  rosa_openshift_version = regex("^[0-9]+\\.[0-9]+", var.ocp_version)
  account_role_policies  = data.rhcs_hcp_policies.all_policies.account_role_policies
  all_versions           = data.rhcs_versions.all[0]
  operator_role_policies = data.rhcs_hcp_policies.all_policies.operator_role_policies
  tags                   = var.additional_tags
}

# module "create_account_roles" {
  
#   count = var.create_account_roles ? 1 : 0

#   source  = "terraform-redhat/rosa-sts/aws"
#   version = "0.0.15"

#   create_account_roles  = var.create_account_roles
#   create_operator_roles = false

#   account_role_prefix    = var.account_role_prefix
#   path                   = local.path
#   rosa_openshift_version = regex("^[0-9]+\\.[0-9]+", var.ocp_version)
#   account_role_policies  = data.rhcs_hcp_policies.all_policies.account_role_policies
#   all_versions           = data.rhcs_versions.all[0]
#   operator_role_policies = data.rhcs_hcp_policies.all_policies.operator_role_policies
#   tags                   = var.additional_tags
# }

resource "time_sleep" "wait_10_seconds" {
  depends_on = [ module.create_account_roles ]

  create_duration = "10s"
}