module "factory_stack" {
  source = "../../../../modules/factory-stack"

  cluster_name            = var.cluster_name
  class_name              = var.class_name
  environment             = var.environment
  openshift_version       = var.openshift_version
  aws_region              = var.aws_region
  private_cluster         = var.private_cluster
  multi_az                = var.multi_az
  business_metadata       = var.business_metadata
  network                 = var.network
  acm                     = var.acm
  gitops                  = var.gitops
  machine_pools           = var.machine_pools
  enable_acm_registration = var.enable_acm_registration
  enable_gitops_bootstrap = var.enable_gitops_bootstrap

  ocm_token                                 = var.ocm_token
  ocm_url                                   = var.ocm_url
  create_account_roles                      = var.create_account_roles
  create_oidc                               = var.create_oidc
  create_operator_roles                     = var.create_operator_roles
  managed_oidc                              = var.managed_oidc
  pod_cidr                                  = var.pod_cidr
  service_cidr                              = var.service_cidr
  aws_additional_compute_security_group_ids = var.aws_additional_compute_security_group_ids
  managed_cluster_kubeconfig_filename       = var.managed_cluster_kubeconfig_filename
  acmhub_kubeconfig_filename                = var.acmhub_kubeconfig_filename
  gitops_repo_username                      = var.gitops_repo_username
  gitops_repo_password                      = var.gitops_repo_password
  temp_dir                                  = var.temp_dir
}
