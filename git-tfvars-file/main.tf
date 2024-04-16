
## Load the tfvars file
data "local_file" "tfvars_file_content" {
  filename  = local.tfvars_file
}

## GitHub: Commit tfvar file to remote repository
resource "github_repository_file" "commit_tfvars_file" {
  repository                = var.git_repository
  branch                    = var.git_base_branch
  file                      = format("tfvars/%s/%s/%s.tfvars", var.business_unit, var.aws_account, var.cluster_name)
  content                   = data.local_file.tfvars_file_content.content
  commit_message            = local.message
  commit_author             = var.git_commit_email
  commit_email              = var.git_commit_email
  overwrite_on_create       = true
}