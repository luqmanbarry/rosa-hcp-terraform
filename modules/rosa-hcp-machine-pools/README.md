# rosa-hcp-machine-pools

Creates additional ROSA HCP machine pools after the core cluster exists.

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
