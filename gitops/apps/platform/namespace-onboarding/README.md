# Namespace Onboarding

Creates OpenShift projects and applies common namespace guardrails.

## What It Manages

- `Project`
- optional `ResourceQuota`
- optional `LimitRange`
- optional namespace-scoped `RoleBinding` resources for groups, service accounts, or explicit subject lists
- optional default `NetworkPolicy` resources
- optional `Template` for OpenShift self-service project requests

## Values

`namespaces` is a list of namespace definitions. Each item can include:

- `name`: required namespace or project name
- `displayName`: optional project display name
- `description`: optional project description
- `nodeSelector`: optional project-level node selector
- `labels`: optional metadata labels
- `annotations`: optional metadata annotations
- `resourceQuota`: optional quota definition
- `limitRange`: optional default resource policy
- `networkPolicies`: optional namespace network policy defaults
- `roleBindings`: optional list of namespace role bindings

The chart also supports a top-level `projectRequestTemplate` block for self-service project creation. Use that with the `self-provisioner` chart when you want new user-created projects to inherit quotas, limit ranges, and network policies.

## Example

```yaml
namespaces:
  - name: team-a-dev
    displayName: Team A Development
    description: Shared namespace for Team A development workloads
    labels:
      tenant: team-a
      environment: dev
    resourceQuota:
      name: team-a-quota
      hard:
        requests.cpu: "8"
        requests.memory: 16Gi
        limits.cpu: "16"
        limits.memory: 32Gi
        persistentvolumeclaims: "10"
    limitRange:
      name: team-a-defaults
      limits:
        - type: Container
          default:
            cpu: 500m
            memory: 1Gi
          defaultRequest:
            cpu: 100m
            memory: 256Mi
    roleBindings:
      - group: team-a-developers
        role: edit
      - group: team-a-operators
        role: admin
    networkPolicies:
      defaultDenyIngress: true
      allowSameNamespaceIngress: true
      allowClusterDNS: true
```

## Notes

- If `namespaces` is empty, the chart renders no resources.
- Quota and limit range values are passed through directly, so teams can use the normal Kubernetes schema.
- This chart is intended for tenant and workload onboarding, not cluster-scoped RBAC. Use `groups-rbac` for cluster-wide role bindings.
- `roleBindings` supports three patterns:
  - `group` for a single group binding
  - `serviceAccount` for a namespace or cross-namespace service account binding
  - `subjects` for explicit Kubernetes RBAC subjects
- `projectRequestTemplate` creates the reusable template object only. The cluster-wide `Project` configuration that points to the template is owned by the `self-provisioner` chart.
