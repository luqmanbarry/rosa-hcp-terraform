
## GET ADMIN AUTHN DETAILS FROM VAULT
data "vault_kv_secret_v2" "acmhub_credentials" {
  count = var.acmhub_pull_from_vault ? 1 : 0
  mount = var.ocp_vault_secret_engine_mount
  name  = local.acmhub_secret_name
}

resource "null_resource" "set_acmhub_kubeconfig" {
  depends_on = [ data.vault_kv_secret_v2.acmhub_credentials ]

  ## Empty the ~/.kube/config file
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "> $KUBECONFIG"
    environment = {
      KUBECONFIG = var.default_kubeconfig_filename
    }
  }

  # Login to the kube cluster - New kubeconfig file will be created
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "oc login -u $USERNAME -p $PASSWORD $API_SERVER --insecure-skip-tls-verify"

    environment = {
      USERNAME   = local.acmhub_username
      PASSWORD   = local.acmhub_password
      API_SERVER = local.acmhub_api_url
    }
  }

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "oc projects --insecure-skip-tls-verify | head"
  }

  triggers = {
    timestamp = "${timestamp()}"
  }
}

resource "local_file" "backup_acmhub_kubeconfig_file" {
  depends_on = [ null_resource.set_acmhub_kubeconfig ]
  source     = var.default_kubeconfig_filename
  filename   = var.acmhub_kubeconfig_filename
}
