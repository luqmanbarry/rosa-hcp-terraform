## Declare common vars
locals {
  tfvars_file               = format("../tfvars/%s/%s/%s.tfvars", var.business_unit, var.aws_account, var.cluster_name)
  action_taken              = var.git_action_taken
  custom_cluster_name       = format("%s-%s-%s", var.business_unit, var.openshift_environment, var.cluster_name)
  feature_branch            = format("%s/%s/CIJob-%s", local.action_taken, local.custom_cluster_name, var.git_ci_job_number)
  pr_title                  = replace(local.feature_branch, "/", " - ")
  tfvar_message             = format("TFVars for cluster: '%s'", local.custom_cluster_name)
  ci_message                = format("CI Job Identifier: %s", var.git_ci_job_identifier)
  message                   = format("Action Taken: %s\n%s\n%s", local.action_taken, local.tfvar_message, local.ci_message)
}