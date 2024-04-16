locals {
  rosa_details_secret_name      = format("%s/%s/%s", var.business_unit, var.admin_creds_vault_secret_name_prefix, var.cluster_name)
  default_ingress_cr            = "${path.module}/.patches/default-ingress-cr.yaml"
  default_ingress_patch         = "${path.module}/.patches/default-ingress-patch.json"
  ingress_name                  = var.custom_ingress_name
  ingress_child_res_namespace   = "openshift-ingress"
  ingress_cr_namespace          = "openshift-ingress-operator"
  ingress_scope                 = "Internal" # Private Network Deployment - Other option is External
  ingress_labels                = {
    "ingress-role"              = local.ingress_name
    format("node-role.kubernetes.io/%s", var.custom_ingress_name) = ""
    "cert_lease_ttl_seconds"                   = var.vault_pki_ttl
    "ingress_name"              = local.ingress_name
    "hypershift.openshift.io/managed"   = "true"
  }
  custom_base_domain            = format("%s.%s.%s.%s.%s", var.cluster_name, var.openshift_environment, var.aws_region, var.business_unit, var.base_dns_domain)
  custom_ingress_domain         = format("%s.%s", var.custom_ingress_domain_prefix, local.custom_base_domain)
  pki_backend_mount_path        = "pki"
  backend_role_name             = format("%s-%s-%s", var.business_unit, var.openshift_environment, var.cluster_name)
  backend_role_path             = format("pki/roles/%s", local.backend_role_name)
  backend_cert_path             = format("pki/issue/%s", local.backend_role_name)
  
  ingress_tls_root_ca           = vault_pki_secret_backend_cert.ingress_certs.certificate
  ingress_tls_ca_chain          = vault_pki_secret_backend_cert.ingress_certs.ca_chain
  ingress_tls_key               = vault_pki_secret_backend_cert.ingress_certs.private_key
  ingress_tls_crt               = join("\n", [vault_pki_secret_backend_cert.ingress_certs.certificate], [vault_pki_secret_backend_cert.ingress_certs.ca_chain])
}
