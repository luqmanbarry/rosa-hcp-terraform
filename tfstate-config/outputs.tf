# output "bucket_exists" {
#   value = strcontains(file(local.bucket_check_output), "Not Found")
#   depends_on = [ null_resource.check_bucket, aws_s3_bucket.tftate_bucket, data.aws_s3_bucket.get_bucket ]
# }

# output "bucket_name" {
#   value = var.tfstate_s3_bucket_name
#   depends_on = [ null_resource.check_bucket, aws_s3_bucket.tftate_bucket, data.aws_s3_bucket.get_bucket ]
# }

# output "bucket_id" {
#   value = strcontains(file(local.bucket_check_output), "Not Found") ? data.aws_s3_bucket.get_bucket.*.id : aws_s3_bucket.tftate_bucket.*.id
#   depends_on = [ null_resource.check_bucket, aws_s3_bucket.tftate_bucket, data.aws_s3_bucket.get_bucket ]
# }

# output "bucket_arn" {
#   value = strcontains(file(local.bucket_check_output), "Not Found") ? data.aws_s3_bucket.get_bucket.*.arn : aws_s3_bucket.tftate_bucket.*.arn
#   depends_on = [ null_resource.check_bucket, aws_s3_bucket.tftate_bucket, data.aws_s3_bucket.get_bucket ]
# }

# output "state_files" {
#   value = data.aws_s3_objects.state_files.*.keys
#   depends_on = [ null_resource.check_bucket, aws_s3_bucket.tftate_bucket, data.aws_s3_bucket.get_bucket ]
# }