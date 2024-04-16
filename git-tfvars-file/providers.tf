terraform {
  required_providers {

    github = {
      source  = "integrations/github"
      version = "~> 6"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

# Configure the GitHub Provider - OAuth / Personal Access Token
provider "github" {
  token               = var.git_token
  # base_url            = var.git_base_url # UNCOMMENT IF GIT ENTERPRISE
  owner               = var.git_owner # UNCOMMENT IF GIT ENTERPRISE
}

provider "aws" {
  # Authentication crdentials will be provided as env vars
}