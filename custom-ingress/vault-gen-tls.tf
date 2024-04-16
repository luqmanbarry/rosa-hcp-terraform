## Vault: Mount the PKI backend (if engine not enabled)
# resource "vault_mount" "pki_secret_backend" {
#   type = var.vault_pki_path
#   path = local.pki_backend_mount_path
# }

## Vault: Create PKI Role
resource "vault_pki_secret_backend_role" "pki_role" {
  # depends_on          = [ vault_mount.pki_secret_backend ]
  backend             = var.vault_pki_path
  name                = local.backend_role_name
  ttl                 = var.vault_pki_ttl
  max_ttl             = var.vault_pki_ttl
  key_type            = "rsa"
  key_bits            = 2048
  allowed_domains     = [local.custom_ingress_domain]
  allow_subdomains    = true
  use_csr_common_name = true
  use_csr_sans        = true
  client_flag         = true
  allow_localhost     = true
  allow_ip_sans       = true
  allow_bare_domains  = true
}

## CREATE PKI BACKEND ROLE
# resource "null_resource" "pki_role" {
#   provisioner "local-exec" {
#     interpreter = [ "/bin/bash", "-c" ]
#     command = "${path.module}/.cmd/create-pki-role.sh"

#     environment = {
#         VAULT_ADDR     = var.vault_addr
#         CUSTOM_DOMAIN  = local.custom_base_domain
#         ROLE_NAME      = local.backend_role_name
#         TOKEN          = "$TOKEN"
#     }
#   }
# }

resource "time_sleep" "wait_for_pki_role" {
  # depends_on      = [ null_resource.pki_role ]
  depends_on      = [ vault_pki_secret_backend_role.pki_role ]
  create_duration = "10s"
}


## Vault: Request TLS certificates
resource "vault_pki_secret_backend_cert" "ingress_certs" {
  depends_on            = [ time_sleep.wait_for_pki_role ]
  backend               = var.vault_pki_path
  name                  = local.backend_role_name
  common_name           = local.custom_ingress_domain
  alt_names             = [format("*.%s", local.custom_ingress_domain)]
  exclude_cn_from_sans  = true
  ttl                   = var.vault_pki_ttl
  format                = "pem"
}