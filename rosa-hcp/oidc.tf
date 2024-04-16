## CREATE OIDC CONFIG
resource "rhcs_rosa_oidc_config" "oidc_config" {
  managed = var.managed_oidc
}

module "oidc_provider" {
  source  = "terraform-redhat/rosa-sts/aws"
  version = "0.0.15"

  create_operator_roles = false
  create_oidc_provider  = true

  cluster_id = ""
  
  rh_oidc_provider_thumbprint = rhcs_rosa_oidc_config.oidc_config.thumbprint
  rh_oidc_provider_url        = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
  tags                        = var.additional_tags
  path                        = var.path
}

resource "time_sleep" "wait_for_oidc" {
  depends_on      = [ module.oidc_provider ]
  create_duration = "15s"
}