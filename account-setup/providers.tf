terraform {
  required_providers {
    
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

provider "aws" {
  # Authentication crdentials will be provided as env vars
  region = var.aws_region
}

provider "rhcs" {
  token = var.ocm_token
  url   = var.ocm_url
}