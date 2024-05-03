module "rosa-hcp_operator-roles" {
 
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/operator-roles"
  version = "1.6.1-prerelease.2"

  oidc_endpoint_url           = module.rosa-hcp_oidc-config-and-provider.oidc_endpoint_url
  operator_role_prefix        = local.operator_role_prefix
  path                        = local.path
  
  tags = merge(
    {
      cluster_name = var.cluster_name
    },
    var.additional_tags
  )
}

resource "time_sleep" "wait_for_operator_roles" {
  depends_on = [module.rosa-hcp_operator-roles]

  create_duration = "15s"
}