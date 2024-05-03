terraform {
  required_providers {

    vault = {
      source = "hashicorp/vault"
      version = "~> 3"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }

    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1"
    }
  }
}

provider "vault" {
  address         = var.vault_addr
  token           = var.vault_token
  # auth_login {
  #   path = "auth/approle/login"

  #   parameters = {
  #     role_id   = var.vault_login_approle_role_id
  #     secret_id = var.vault_login_approle_secret_id
  #   }
  # }
}

provider "kubernetes" {
  config_path    = var.managed_cluster_kubeconfig_filename
  insecure       = true
  alias          = "managed_cluster"
}


provider "aws" {
  # Authentication crdentials will be provided as env vars
}

provider "rhcs" {
  token = var.ocm_token
  url   = var.ocm_url
}