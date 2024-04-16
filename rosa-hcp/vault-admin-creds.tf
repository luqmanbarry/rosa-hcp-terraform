## Vault: Generate username
resource "random_uuid" "username" {
  count = var.admin_creds_vault_generate ? 1 : 0
}

## Vault: Generate password
resource "random_password" "password" {
  count = var.admin_creds_vault_generate ? 1 : 0
  length            = 40
  lower             = true
  min_lower         = 10
  upper             = true
  min_upper         = 10
  numeric           = true
  min_numeric       = 10
  special           = true
  min_special       = 5
  override_special  = "-_()[]<>=?+"
}

resource "time_sleep" "wait_for_api_url" {
  depends_on  = [ rhcs_cluster_wait.wait_for_cluster_build ]
  create_duration = "600s"
}

data "rhcs_cluster_rosa_classic" "get_cluster" {
  depends_on  = [ time_sleep.wait_for_api_url ]
  id          = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
}

## Vault: Write Cluster Details
resource "vault_kv_secret_v2" "rosa_cluster_details" {
  depends_on = [ data.rhcs_cluster_rosa_classic.get_cluster ]
  mount      = var.ocp_vault_secret_engine_mount
  name       = local.rosa_details_secret_name

  data_json = jsonencode({
    # username            = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.admin_credentials.username
    # password            = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.admin_credentials.password
    cluster_name        = data.rhcs_cluster_rosa_classic.get_cluster.name
    console_url         = data.rhcs_cluster_rosa_classic.get_cluster.console_url
    default_api_url     = data.rhcs_cluster_rosa_classic.get_cluster.api_url
    cluster_id          = data.rhcs_cluster_rosa_classic.get_cluster.id
  })

  custom_metadata {
    data = {
      business_unit = var.business_unit
      cluster_name  = var.cluster_name
    }
  }
}