
terraform {
  backend "s3" {
    encrypt = true
  }
  # All other configs will be provided in the command line - View README.md
}