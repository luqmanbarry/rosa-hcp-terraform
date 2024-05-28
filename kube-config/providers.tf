terraform {
  required_providers {

    vault = {
      source = "hashicorp/vault"
      version = "~> 3"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2"
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

provider "aws" {
  # Authentication crdentials will be provided as env vars
  region = var.aws_region
  # export AWS_ACCESS_KEY_ID="anaccesskey"
  # export AWS_SECRET_ACCESS_KEY="asecretkey"
  # export AWS_SESSION_TOKEN="session-token"
  # export AWS_REGION="us-east-1"
}