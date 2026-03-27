# user-workload-monitoring

Configures OpenShift monitoring for user workloads.

## Responsibilities

- manages `cluster-monitoring-config`
- manages `user-workload-monitoring-config`
- controls retention, storage, and optional remote write

## Default Behavior

- enabled
- uses persistent storage values from the chart inputs
- remote write remains disabled unless explicitly configured

If you enable remote write, define the matching `ExternalSecret` in the same values file so the target `Secret` exists before monitoring uses it.
