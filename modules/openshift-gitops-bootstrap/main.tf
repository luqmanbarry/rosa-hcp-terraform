provider "kubernetes" {
  config_path = var.managed_cluster_kubeconfig_filename
}

locals {
  create_repo_secret = length(trimspace(var.gitops_repo_username)) > 0 && length(trimspace(var.gitops_repo_password)) > 0
  root_app_values = merge(
    var.gitops_values,
    {
      git = {
        repoURL        = var.gitops_git_repo_url
        targetRevision = var.gitops_target_revision
      }
    }
  )
}

resource "kubernetes_manifest" "gitops_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.gitops_namespace
      labels = {
        "openshift.io/cluster-monitoring" = "true"
      }
    }
  }
}

resource "kubernetes_manifest" "gitops_operator_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.gitops_operator_namespace
      labels = {
        "openshift.io/cluster-monitoring" = "true"
      }
    }
  }
}

resource "kubernetes_manifest" "gitops_operator_group" {
  depends_on = [kubernetes_manifest.gitops_operator_namespace]

  manifest = {
    apiVersion = "operators.coreos.com/v1"
    kind       = "OperatorGroup"
    metadata = {
      name      = "openshift-gitops-operator"
      namespace = var.gitops_operator_namespace
    }
    spec = {
      targetNamespaces = [var.gitops_operator_namespace]
    }
  }
}

resource "kubernetes_manifest" "gitops_operator_subscription" {
  depends_on = [kubernetes_manifest.gitops_operator_group]

  manifest = {
    apiVersion = "operators.coreos.com/v1alpha1"
    kind       = "Subscription"
    metadata = {
      name      = "openshift-gitops-operator"
      namespace = var.gitops_operator_namespace
    }
    spec = {
      channel             = var.gitops_channel
      installPlanApproval = "Automatic"
      name                = "openshift-gitops-operator"
      source              = "redhat-operators"
      sourceNamespace     = "openshift-marketplace"
    }
  }
}

resource "null_resource" "wait_for_operator_ready" {
  depends_on = [kubernetes_manifest.gitops_operator_subscription]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      oc --kubeconfig="$KUBECONFIG" wait --for=condition=AtLatestKnown subscription/openshift-gitops-operator -n "$OPERATOR_NAMESPACE" --timeout=10m
      oc --kubeconfig="$KUBECONFIG" wait --for=condition=Available deployment/gitops-operator-controller-manager -n "$OPERATOR_NAMESPACE" --timeout=10m
    EOT
    environment = {
      KUBECONFIG         = var.managed_cluster_kubeconfig_filename
      OPERATOR_NAMESPACE = var.gitops_operator_namespace
    }
  }

  triggers = {
    operator_namespace = var.gitops_operator_namespace
    gitops_channel     = var.gitops_channel
  }
}

resource "kubernetes_manifest" "repo_secret" {
  count      = local.create_repo_secret ? 1 : 0
  depends_on = [kubernetes_manifest.gitops_namespace, null_resource.wait_for_operator_ready]

  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "root-repository"
      namespace = var.gitops_namespace
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    stringData = {
      name     = "root-repository"
      type     = "git"
      url      = var.gitops_git_repo_url
      username = var.gitops_repo_username
      password = var.gitops_repo_password
    }
  }
}

resource "null_resource" "wait_for_argocd_ready" {
  depends_on = [null_resource.wait_for_operator_ready, kubernetes_manifest.gitops_namespace]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      oc --kubeconfig="$KUBECONFIG" wait --for=condition=Available deployment/openshift-gitops-server -n "$GITOPS_NAMESPACE" --timeout=10m
      oc --kubeconfig="$KUBECONFIG" wait --for=condition=Available deployment/openshift-gitops-repo-server -n "$GITOPS_NAMESPACE" --timeout=10m
    EOT
    environment = {
      KUBECONFIG       = var.managed_cluster_kubeconfig_filename
      GITOPS_NAMESPACE = var.gitops_namespace
    }
  }

  triggers = {
    gitops_namespace = var.gitops_namespace
  }
}

resource "kubernetes_manifest" "platform_project" {
  depends_on = [null_resource.wait_for_argocd_ready]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "platform"
      namespace = var.gitops_namespace
    }
    spec = {
      description = "Platform-owned GitOps applications"
      sourceRepos = [var.gitops_git_repo_url]
      destinations = [{
        namespace = "*"
        server    = "https://kubernetes.default.svc"
      }]
      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
      namespaceResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  }
}

resource "kubernetes_manifest" "workloads_project" {
  depends_on = [null_resource.wait_for_argocd_ready]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "workloads"
      namespace = var.gitops_namespace
    }
    spec = {
      description = "Workload-owned GitOps applications"
      sourceRepos = ["*"]
      destinations = [{
        namespace = "*"
        server    = "https://kubernetes.default.svc"
      }]
      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
      namespaceResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  }
}

resource "kubernetes_manifest" "root_application" {
  depends_on = [
    kubernetes_manifest.gitops_namespace,
    null_resource.wait_for_argocd_ready,
    kubernetes_manifest.repo_secret,
    kubernetes_manifest.platform_project,
    kubernetes_manifest.workloads_project,
  ]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = format("%s-root", var.cluster_name)
      namespace = var.gitops_namespace
    }
    spec = {
      destination = {
        namespace = var.gitops_namespace
        server    = "https://kubernetes.default.svc"
      }
      project = "platform"
      source = {
        repoURL        = var.gitops_git_repo_url
        targetRevision = var.gitops_target_revision
        path           = var.gitops_root_app_path
        helm = {
          valuesObject = local.root_app_values
        }
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}
