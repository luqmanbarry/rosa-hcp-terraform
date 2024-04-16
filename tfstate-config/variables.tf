
variable "tfstate_s3_bucket_name" {
  type = string
  default = "rosa-sts-001"
}

variable "additional_tags" {
  default = {
    Terraform   = "true"
    environment = "dev"
    contact     = "lbarry@redhat.com"
  }
  description = "Additional AWS resource tags"
  type        = map(string)
}