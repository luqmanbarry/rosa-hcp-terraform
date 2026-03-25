output "machine_pool_names" {
  value = keys(local.machine_pools_by_name)
}

