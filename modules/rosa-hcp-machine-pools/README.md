# rosa-hcp-machine-pools

This module creates extra ROSA HCP machine pools after the cluster exists.

## Responsibilities

- provisions named machine pools
- supports autoscaling bounds
- supports worker labels and tags
- supports per-pool instance types

## Typical Use Cases

- observability pool
- AAP pool
- OpenShift AI pool
- future virtualization or specialized workload pools
