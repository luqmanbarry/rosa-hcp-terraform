
## CREATE S3 BUCKET
resource "aws_s3_bucket" "tftate_bucket" {

  bucket = var.tfstate_s3_bucket_name

  force_destroy = true

  tags = var.additional_tags

  lifecycle {
    ignore_changes = [ tags, bucket ]
  }
}

## ENABLE BUCKET VERSIONING
resource "aws_s3_bucket_versioning" "tfstate_bucket" {
  depends_on = [ aws_s3_bucket.tftate_bucket ]

  bucket = var.tfstate_s3_bucket_name

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = [ bucket ]
  }
}
