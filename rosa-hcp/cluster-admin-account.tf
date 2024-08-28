# Dumb resource to trigger other resources
resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

## Vault: Generate username
resource "random_uuid" "username" {
  count = var.admin_creds_vault_generate ? 1 : 0

  # lifecycle {
  #   replace_triggered_by = [ null_resource.always_run ]
  # }
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
  override_special  = "-_[]=?+.%@#"

  # lifecycle {
  #   replace_triggered_by = [ null_resource.always_run ]
  # }
}

resource "time_sleep" "wait_for_api_url" {
  # depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
  depends_on      = [ module.rosa-hcp_rosa-cluster-hcp ]
  create_duration = "300s"
}

data "rhcs_cluster_rosa_hcp" "get_cluster" {
  depends_on  = [ time_sleep.wait_for_api_url ]
  # id          = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  id          = module.rosa-hcp_rosa-cluster-hcp.cluster_id
}

module "rosa-hcp_idp-htpasswd" {

  source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
  version = "1.6.1-prerelease.2"

  # depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
  depends_on  = [ module.rosa-hcp_rosa-cluster-hcp ]

  cluster_id         = data.rhcs_cluster_rosa_hcp.get_cluster.id
  name               = local.cluster_admin_idp
  idp_type           = "htpasswd"
  htpasswd_idp_users = [
    {
      username = local.username
      password = local.password
    }
  ]

}

resource "null_resource" "grant_user_cluster_admin" {
  depends_on  = [ module.rosa-hcp_idp-htpasswd ]

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "rosa login --token=\"$OCM_TOKEN\" &> /dev/null"
    environment = {
      OCM_TOKEN = var.ocm_token
    }
  }

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "rosa grant user cluster-admin --user \"$USER_NAME\" --cluster=\"$CLUSTER_ID\""
    environment = {
      CLUSTER_ID  = data.rhcs_cluster_rosa_hcp.get_cluster.id
      USER_NAME   = local.username
    }
  }

  # lifecycle {
  #   replace_triggered_by = [ null_resource.always_run ]
  # }
}

## Vault: Write Cluster Details
resource "vault_kv_secret_v2" "rosa_cluster_details" {
  depends_on = [ null_resource.grant_user_cluster_admin ]
  count      = var.admin_creds_save_to_vault ? 1 : 0
  mount      = var.ocp_vault_secret_engine_mount
  name       = local.rosa_details_secret_name

  data_json = jsonencode({
    username            = local.username
    password            = local.password
    cluster_name        = data.rhcs_cluster_rosa_hcp.get_cluster.name
    console_url         = data.rhcs_cluster_rosa_hcp.get_cluster.console_url
    default_api_url     = data.rhcs_cluster_rosa_hcp.get_cluster.api_url
    cluster_id          = data.rhcs_cluster_rosa_hcp.get_cluster.id
  })

  # custom_metadata {
  #   data = {
  #     business_unit = var.business_unit
  #     cluster_name  = var.cluster_name
  #   }
  # }

  # lifecycle {
  #   replace_triggered_by = [ null_resource.always_run ]
  # }
}

resource "time_sleep" "wait_for_oauth_pods_to_rollout" {
  # depends_on  = [ rhcs_cluster_rosa_hcp.rosa_hcp_cluster ]
  depends_on      = [ vault_kv_secret_v2.rosa_cluster_details ]
  create_duration = "180s"
}
