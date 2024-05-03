
## GET ADMIN AUTHN DETAILS FROM VAULT
data "vault_kv_secret_v2" "managed_cluster_credentials" {
  depends_on = [ null_resource.set_acmhub_kubeconfig ]
  mount = var.ocp_vault_secret_engine_mount
  name  = local.managed_cluster_secret_name
}

resource "null_resource" "set_managed_cluster_kubeconfig" {
  depends_on = [ data.vault_kv_secret_v2.managed_cluster_credentials ]

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
    command = "oc login -u \"$USERNAME\" -p \"$PASSWORD\" \"$API_SERVER\" --insecure-skip-tls-verify"

    environment = {
      USERNAME   = local.managed_cluster_username
      PASSWORD   = local.managed_cluster_password
      API_SERVER = local.managed_cluster_api_url
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

resource "null_resource" "backup_managed_cluster_kubeconfig_file" {
  depends_on = [ null_resource.set_managed_cluster_kubeconfig ]

  ## Empty the ~/.kube/config file
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "cp -v \"$SRC\" \"$DEST\" "
    environment = {
      SRC  = var.default_kubeconfig_filename
      DEST = var.managed_cluster_kubeconfig_filename
    }
  }

  triggers = {
    timestamp = "${timestamp()}"
  }
}

# resource "local_file" "backup_managed_cluster_kubeconfig_file" {
#   depends_on = [ null_resource.set_managed_cluster_kubeconfig ]
#   source     = var.default_kubeconfig_filename
#   filename   = var.managed_cluster_kubeconfig_filename
# }
