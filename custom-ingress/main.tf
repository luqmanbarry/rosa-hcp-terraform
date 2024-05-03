
# Ref: https://cloud.redhat.com/experts/rosa/ingress-controller/

## Vault: Get cluster details
data "vault_kv_secret_v2" "rosa_cluster_details" {
  mount = var.ocp_vault_secret_engine_mount
  name = local.rosa_details_secret_name
}

## ROSA: Deploy MachineConfigPool
module "rosa-hcp_machine-pool" {
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/machine-pool"
  version = "1.6.1-prerelease.2"

  count  = length(toset(var.private_subnet_ids))

  depends_on = [ data.vault_kv_secret_v2.rosa_cluster_details ]
  
  name                              = format("%s-%s", var.custom_ingress_name, count.index)
  cluster_id                        = lookup(data.vault_kv_secret_v2.rosa_cluster_details.data, "cluster_id")
  auto_repair                       = true
  aws_node_pool                     = {
    instance_type       = var.custom_ingress_machine_type
    tags                = merge(local.ingress_labels, var.default_mp_labels)
  }
  autoscaling                       = {
    enabled = true
    min_replicas                    = 1
    max_replicas                    = var.custom_ingress_machine_pool_max_replicas
  }
  labels                            = merge(local.ingress_labels, var.additional_tags)
  openshift_version                 = var.ocp_version
  # subnet_id                         = (length(var.private_subnet_ids) > 2 ? null : one(var.private_subnet_ids) )
  subnet_id                         = var.private_subnet_ids[count.index]

}


resource "time_sleep" "wait_for_machine_pool" {
  depends_on = [ module.rosa-hcp_machine-pool ]
  create_duration = "300s"
}


## ROSA: Get details of default IngressController
data "kubernetes_resource" "default_ingress" {
  depends_on = [ time_sleep.wait_for_machine_pool ]
  provider    = kubernetes.managed_cluster
  api_version        = "operator.openshift.io/v1"
  kind               = "IngressController" 

  metadata {
    name = "default"
    namespace = "openshift-ingress-operator"
  }
}

## Local Filesystem: Save default IngressController CR to file
resource "local_file" "default_ingress_cr" {
  depends_on = [ data.kubernetes_resource.default_ingress ]
  content    = yamlencode(data.kubernetes_resource.default_ingress.object)
  filename = local.default_ingress_cr
}


## ROSA: Add namespaceSelector exclusion list to default IngressController
resource "null_resource" "default_ingress_patch" {
  depends_on = [ local_file.default_ingress_cr ]

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "oc patch -f $INGRESS_CR --type=merge --patch-file=$INGRESS_PATCH --v=3"

    environment = {
        INGRESS_CR      = local.default_ingress_cr
        INGRESS_PATCH   = local.default_ingress_patch
    }
  }

  triggers = {
    timestamp = "${timestamp()}"
  }
}

## ROSA: Create TLS secret for the second IngressController domain
resource "kubernetes_secret" "custom-ingress-certs-secret" {
  depends_on = [ null_resource.default_ingress_patch ]
  provider    = kubernetes.managed_cluster

  metadata         {
    name          = local.ingress_name
    namespace     = local.ingress_child_res_namespace
    labels        = local.ingress_labels
    annotations   = {
        "ingress.operator.openshift.io/auto-delete-load-balancer"  = "true"
    }
  }
  data = {
    "tls.key" = local.ingress_tls_key
    "tls.crt" = local.ingress_tls_crt
  }

  type = "Opaque"
  
}

## ROSA: Create the second IngressConroller CR in openshift-ingress-operator namespace
resource "kubernetes_manifest" "custom-ingress" {

  depends_on  = [ kubernetes_secret.custom-ingress-certs-secret ]
  provider    = kubernetes.managed_cluster

  manifest   = {
    "apiVersion"        = "operator.openshift.io/v1"
    "kind"              = "IngressController"
    "metadata"          = {
      "name"            = local.ingress_name
      "namespace"       = local.ingress_cr_namespace
      "labels"          = local.ingress_labels
      "annotations"     = {
        "ingress.operator.openshift.io/auto-delete-load-balancer" = "true"
      }
      "finalizers" = [
        "ingresscontroller.operator.openshift.io/finalizer-ingresscontroller",
      ]
    }
    "spec" = {
      "namespaceSelector" = {
        "matchExpressions" = [
          {
            "key" = "ingress-role"
            "operator" = "In"
            "values" = var.ingress_sharding_tags
          },
        ]
      }
      "clientTLS" = {
        "clientCA" = {
          "name" = ""
        }
        "clientCertificatePolicy" = ""
      }
      "defaultCertificate" = {
        "name" = local.ingress_name
      }
      "domain" = local.custom_ingress_domain
      "endpointPublishingStrategy" = {
        "loadBalancer" = {
          "dnsManagementPolicy" = "Unmanaged"
          "providerParameters" = {
            "aws" = {
              "networkLoadBalancer" = {}
              "type" = "NLB"
            }
            "type" = "AWS"
          }
          "scope" = local.ingress_scope
        }
        "type" = "LoadBalancerService"
      }
      "httpCompression" = {}
      "httpEmptyRequestsPolicy" = "Respond"
      "httpErrorCodePages" = {
        "name" = ""
      }
      "replicas" = var.ingress_pod_replicas
      "tuningOptions" = {
        "reloadInterval" = "0s"
      }
      "unsupportedConfigOverrides" = null
      "nodePlacement" = {
        "nodeSelector" = {
          "matchLabels" = {
            format("node-role.kubernetes.io/%s", var.custom_ingress_name) = ""
          }
        }
        "tolerations" = [
          {
            "key" = "node-role.kubernetes.io/infra"
            "effect" = "NoSchedule"
            "operator" = "Exists"
          },
          {
            "key" = "node-role.kubernetes.io/worker"
            "effect" = "NoSchedule"
            "operator" = "Exists"
          },
          {
            "key" = format("node-role.kubernetes.io/%s", var.custom_ingress_name)
            "effect" = "NoSchedule"
            "operator" = "Exists"
          }
        ]
      }
      "logging" = {
        "access" = {
          "destination" = {
            "type" = "Container"
          }
          "httpCaptureHeaders" = {
            "request" = [
              {
                "maxLength" = 200
                "name" = "Host"
              },
            ]
          }
          "logEmptyRequests" = "Log"
        }
      }
    }
  }

  field_manager {
    force_conflicts = true
  }

  wait {
    condition {
      type   = "Admitted"
      status = "True"
    }
  }

  lifecycle {
    replace_triggered_by = [
      kubernetes_secret.custom-ingress-certs-secret.metadata,
      kubernetes_secret.custom-ingress-certs-secret.data
    ]
  }
}


## ROSA: Patch the LB service to specify subnets lists
resource "kubernetes_annotations" "set_elb_subnets" {
  depends_on  = [ kubernetes_manifest.custom-ingress ]
  provider    = kubernetes.managed_cluster

  api_version = "v1"
  kind = "Service"
  metadata {
    name = format("router-%s", local.ingress_name)
    namespace = local.ingress_child_res_namespace
  }
  annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-subnets" = (var.private_cluster ? join(",", var.private_subnet_ids) : join(",", concat(var.private_subnet_ids, var.public_subnet_ids)))
  }
  force = true
}

resource "time_sleep" "wait_for_for_elb" {
  depends_on = [ kubernetes_annotations.set_elb_subnets ]
  create_duration = "30s"
}

## ROSA: Get the NLB name/hostname
data "kubernetes_resource" "custom-ingress-vars" {
  depends_on = [ time_sleep.wait_for_for_elb ]
  provider    = kubernetes.managed_cluster

  api_version = "v1"
  kind        = "Service"

  metadata {
    name      = format("router-%s", local.ingress_name)
    namespace = local.ingress_child_res_namespace
  }
}


locals {
  depends_on = [ data.kubernetes_resource.custom-ingress-vars ]
  nlb_host_name         = data.kubernetes_resource.custom-ingress-vars.object.status.loadBalancer.ingress[0].hostname
  nlb_name              = replace(local.nlb_host_name, "/-.*/", "")
  nlb_region            = var.aws_region
  nlb_hosted_zone_id    = var.hosted_zone_id
}

## AWS: Create a Route53 entry for the new domain / ELB
resource "aws_route53_record" "nlb_hostname" {
  depends_on = [ data.kubernetes_resource.custom-ingress-vars ]
  zone_id = var.hosted_zone_id
  name    = format("*.%s", local.custom_ingress_domain)
  type    = "A"

  alias {
    name                   = local.nlb_host_name
    zone_id                = local.nlb_hosted_zone_id
    evaluate_target_health = true
  }
}