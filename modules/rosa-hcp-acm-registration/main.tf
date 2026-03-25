provider "kubernetes" {
  config_path = var.managed_cluster_kubeconfig_filename
  alias       = "managed_cluster"
}

provider "kubernetes" {
  config_path = var.acmhub_kubeconfig_filename
  alias       = "acmhub_cluster"
}

locals {
  klusterlet_crd_yaml = "${var.temp_dir}/klusterlet_crd_yaml.yaml"
  import_file_yaml    = "${var.temp_dir}/import_file.yaml"
}

resource "null_resource" "prepare_temp_dir" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p \"$DIR\""
    environment = {
      DIR = var.temp_dir
    }
  }

  triggers = {
    temp_dir = var.temp_dir
  }
}

resource "kubernetes_manifest" "hub_managedcluster_cr" {
  provider = kubernetes.acmhub_cluster

  manifest = {
    apiVersion = "cluster.open-cluster-management.io/v1"
    kind       = "ManagedCluster"
    metadata = {
      name = var.cluster_name
    }
    spec = {
      hubAcceptsClient = true
    }
  }

  wait {
    fields = {
      "metadata.creationTimestamp" = ".+"
    }
  }
}

resource "kubernetes_manifest" "hub_klusterletaddonconfig_cr" {
  depends_on = [kubernetes_manifest.hub_managedcluster_cr]
  provider   = kubernetes.acmhub_cluster

  manifest = {
    apiVersion = "agent.open-cluster-management.io/v1"
    kind       = "KlusterletAddonConfig"
    metadata = {
      name      = var.cluster_name
      namespace = var.cluster_name
    }
    spec = {
      applicationManager   = { enabled = true }
      certPolicyController = { enabled = true }
      clusterLabels = {
        cloud  = "auto-detect"
        vendor = "auto-detect"
      }
      clusterName         = var.cluster_name
      clusterNamespace    = var.cluster_name
      iamPolicyController = { enabled = true }
      policyController    = { enabled = true }
      searchCollector     = { enabled = true }
    }
  }

  wait {
    fields = {
      "metadata.creationTimestamp" = ".+"
    }
  }
}

resource "time_sleep" "wait_for_import_secret" {
  depends_on      = [kubernetes_manifest.hub_klusterletaddonconfig_cr]
  create_duration = "30s"
}

data "kubernetes_secret" "import_manifests" {
  depends_on = [time_sleep.wait_for_import_secret]
  provider   = kubernetes.acmhub_cluster

  metadata {
    name      = format("%s-import", var.cluster_name)
    namespace = var.cluster_name
  }
}

resource "local_sensitive_file" "klusterlet_crd_yaml" {
  depends_on = [null_resource.prepare_temp_dir, data.kubernetes_secret.import_manifests]
  content    = try(lookup(data.kubernetes_secret.import_manifests.data, "crds.yaml"), null)
  filename   = local.klusterlet_crd_yaml
}

resource "null_resource" "managed_apply_klusterlet_crd" {
  depends_on = [local_sensitive_file.klusterlet_crd_yaml]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p \"$DIR\" && oc apply --kubeconfig=\"$KUBECONFIG\" -f \"$RESOURCE_FILE\""
    environment = {
      DIR           = var.temp_dir
      KUBECONFIG    = var.managed_cluster_kubeconfig_filename
      RESOURCE_FILE = local.klusterlet_crd_yaml
    }
  }

  triggers = {
    manifest_sha = sha256(nonsensitive(local_sensitive_file.klusterlet_crd_yaml.content))
  }
}

resource "local_sensitive_file" "import_crd_yaml" {
  depends_on = [null_resource.prepare_temp_dir, null_resource.managed_apply_klusterlet_crd]
  content    = try(lookup(data.kubernetes_secret.import_manifests.data, "import.yaml"), null)
  filename   = local.import_file_yaml
}

resource "null_resource" "managed_apply_import_yaml" {
  depends_on = [local_sensitive_file.import_crd_yaml]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "oc apply --kubeconfig=\"$KUBECONFIG\" -f \"$RESOURCE_FILE\""
    environment = {
      KUBECONFIG    = var.managed_cluster_kubeconfig_filename
      RESOURCE_FILE = local.import_file_yaml
    }
  }

  triggers = {
    manifest_sha = sha256(nonsensitive(local_sensitive_file.import_crd_yaml.content))
  }
}
