# rosa-hcp-core

Creates the ROSA HCP cluster by wrapping the upstream `terraform-redhat/rosa-hcp/rhcs` module.

## Responsibilities

- configures RHCS and AWS providers
- provisions the ROSA HCP cluster
- sets networking, private/public posture, and default worker sizing
- applies cluster tags

## Important Behavior

- the default worker pool is created here
- cluster-level autoscaler settings are intentionally disabled until upstream support is fully validated
- default worker sizing still supports autoscaling-like intent through machine-pool inputs and follow-on pools
