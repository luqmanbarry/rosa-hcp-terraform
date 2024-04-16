
## GET ADMIN AUTHN DETAILS FROM VAULT
data "vault_kv_secret_v2" "managed_cluster_credentials" {
  mount = var.ocp_vault_secret_engine_mount
  name  = local.cluster_secret_name
}

## CHECK NAMESPACE EXISTS OR NOT
data "kubernetes_resource" "vault_auth_namespace" {
  depends_on = [ data.vault_kv_secret_v2.managed_cluster_credentials ]
  api_version = "v1"
  kind = "Namespace"
  metadata {
    name = var.vault_auth_backend_kube_namespace
  }
}

## CREATE NAMESPACE FOR HOSTING VAULT SA
resource "kubernetes_namespace" "namespace-vault-auth-backend" {
  count = length(data.kubernetes_resource.vault_auth_namespace.object.metadata.name) > 0 ? 0 : 1
  
  metadata {
    annotations = {
      name = var.vault_auth_backend_kube_namespace
    }
    labels = {
      purpose = "kubernetes-vault-auth-backend"
    }
  
    name = var.vault_auth_backend_kube_namespace
  }
  
}

## CREATE SA
resource "kubernetes_manifest" "serviceaccount-vault-auth-backend" {
  depends_on = [ kubernetes_namespace.namespace-vault-auth-backend ]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = var.vault_auth_backend_kube_sa
      "namespace" = var.vault_auth_backend_kube_namespace
      "labels" = {
        "auth_type" = "vault-kubernetes-auth"
      }
    }
  }
}

## CREATE VAULT SA CLUSTER_ROLE_BINDING
resource "kubernetes_manifest" "clusterrolebinding-vault-sa" {
  depends_on = [ kubernetes_manifest.serviceaccount-vault-auth-backend ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = format("%s-crole-binding", var.vault_auth_backend_kube_sa)
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "system:auth-delegator"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = var.vault_auth_backend_kube_sa
        "namespace" = var.vault_auth_backend_kube_namespace
      },
    ]
  }
}


## CREATE SECRET FOR HOLDING SA_TOKEN
resource "kubernetes_manifest" "secret-vault-sa-token-secret" {
  depends_on = [ kubernetes_manifest.clusterrolebinding-vault-sa ]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/service-account.name" = var.vault_auth_backend_kube_sa
      }
      "name" = var.vault_auth_backend_kube_sa
      "namespace" = var.vault_auth_backend_kube_namespace
    }
    "type" = "kubernetes.io/service-account-token"
  }
}

data "kubernetes_secret" "vault-sa-token-secret" {
  depends_on = [ kubernetes_manifest.secret-vault-sa-token-secret ]
  metadata {
    name = var.vault_auth_backend_kube_sa
    namespace = var.vault_auth_backend_kube_namespace
  }
}


## Ensure kubernetes auth backend is enabled and linked to this SA
data "vault_auth_backends" "check_mount_paths" {
  type = var.vault_auth_backend_type
}

resource "vault_auth_backend" "kubernetes" {
  depends_on = [ data.vault_auth_backends.check_mount_paths ]
  count = (contains(local.found_backend_paths, local.custom_backend_path) ? 0 : 1)
  type = var.vault_auth_backend_type
  path = local.custom_backend_path
}
resource "vault_kubernetes_auth_backend_config" "vault-auth-backend" {
  depends_on             = [ data.vault_auth_backends.check_mount_paths, vault_auth_backend.kubernetes ]
  backend                = local.custom_backend_path
  kubernetes_host        = local.cluster_api_url

  kubernetes_ca_cert     = lookup(data.kubernetes_secret.vault-sa-token-secret.data, "ca.crt")
  token_reviewer_jwt     = lookup(data.kubernetes_secret.vault-sa-token-secret.data, "token")
  disable_iss_validation = "true"
}

## TBD for vault-secret-operator
resource "vault_kubernetes_auth_backend_role" "vault-auth-backend" {
  depends_on                        = [ data.vault_auth_backends.check_mount_paths, vault_auth_backend.kubernetes ]
  backend                           = local.custom_backend_path
  role_name                         = replace(local.backend_role_name, "/", "-")
  bound_service_account_names       = var.vault_auth_backend_bound_sa_names
  bound_service_account_namespaces  = var.vault_auth_backend_bound_sa_namespaces
  token_ttl                         = var.vault_auth_backend_token_ttl
  token_policies                    = var.vault_auth_backend_token_policies
  audience                          = var.vault_auth_backend_audience
  token_bound_cidrs                 = [ var.vpc_cidr_block ]
}