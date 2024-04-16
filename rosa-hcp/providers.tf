terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 3"
    }
    
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1"
    }

  }
}

# Export token using the RHCS_TOKEN environment variable
provider "rhcs" {
  token = var.ocm_token
  url   = var.ocm_url
}

provider "aws" {
  # Authentication crdentials will be provided as env vars
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
