# rosa-hcp-core

This module creates the ROSA HCP cluster.

It does these jobs:

- configures RHCS and AWS providers
- provisions the ROSA HCP cluster
- sets networking, private/public posture, and default worker sizing
- applies cluster tags

## Important Behavior

- the default worker pool is created here
- cluster-level autoscaler settings are intentionally disabled until upstream support is fully validated
- worker sizing is mainly controlled through machine pool inputs and extra pools
