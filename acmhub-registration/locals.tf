locals {
  cluster_name                      = format("%s-%s-%s", var.business_unit, var.openshift_environment, var.cluster_name)
  klusterlet_crd_yaml               = "/tmp/klusterlet_crd_yaml.yaml"
  import_file_yaml                  = "/tmp/import_file.yaml"
}