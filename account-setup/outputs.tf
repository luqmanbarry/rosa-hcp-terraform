output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "additional_security_group" {
  value = aws_security_group.ocp_cluster_sg_config.arn
}

# output "hcp_account_role_policies" {
#   value = data.rhcs_hcp_policies.all_policies.account_role_policies
# }

# output "hcp_operator_role_policies" {
#   value = data.rhcs_hcp_policies.all_policies.operator_role_policies
# }