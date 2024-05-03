## CREATE OIDC CONFIG
module "rosa-hcp_oidc-config-and-provider" {

  source  = "terraform-redhat/rosa-hcp/rhcs//modules/oidc-config-and-provider"
  version = "1.6.1-prerelease.2"

  managed                     = var.managed_oidc
  
  tags = merge(
    {
      cluster_name = var.cluster_name
    },
    var.additional_tags
  )
}

resource "time_sleep" "wait_for_oidc" {
  depends_on      = [ module.rosa-hcp_oidc-config-and-provider ]
  create_duration = "15s"
}