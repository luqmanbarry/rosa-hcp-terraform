module "rosa-hcp_account-iam-resources" {

  source  = "terraform-redhat/rosa-hcp/rhcs//modules/account-iam-resources"
  version = "1.6.1-prerelease.2"
  
  count = var.create_account_roles ? 1 : 0

  account_role_prefix    = local.account_role_prefix
  path                   = local.path
  tags = merge(
    {
      cluster_name = var.cluster_name
    },
    var.additional_tags
  )
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [ module.rosa-hcp_account-iam-resources ]

  create_duration = "10s"
}