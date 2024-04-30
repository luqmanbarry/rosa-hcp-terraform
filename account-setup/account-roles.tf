data "rhcs_versions" "all" {
  count = var.create_account_roles ? 1 : 0
}

data "rhcs_hcp_policies" "all_policies" {}

module "rosa-hcp_account-iam-resources" {
  
  count = var.create_account_roles ? 1 : 0

  # source  = "terraform-redhat/rosa-sts/aws"
  # version = "0.0.15"
 
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/account-iam-resources"
  version = "1.6.1-prerelease.2"

  account_role_prefix    = local.account_role_prefix
  path                   = local.path
  tags                   = var.additional_tags
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [ module.rosa-hcp_account-iam-resources ]

  create_duration = "10s"
}