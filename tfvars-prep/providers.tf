terraform {
  required_providers {

    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }
}


provider "aws" {
  # Authentication crdentials will be provided as env vars
}