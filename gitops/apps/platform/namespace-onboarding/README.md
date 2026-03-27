# Namespace Onboarding

Creates OpenShift projects, applies common namespace guardrails, and can onboard tenant teams into one shared Argo CD instance after admin approval.

## What It Manages

- `Project`
- optional `ResourceQuota`
- optional `LimitRange`
- optional namespace-scoped `RoleBinding` resources for groups, service accounts, or explicit subject lists
- optional default `NetworkPolicy` resources
- optional `Template` for OpenShift self-service project requests
- optional shared tenant `ArgoCD` instance
- optional one `AppProject` per tenant
- optional namespace-scoped RBAC so tenant groups can create Argo CD `Application` objects in their own namespaces
- optional namespace-scoped RBAC so approved tenant groups can create `ApplicationSet` objects in their own namespaces
- optional repo credential `ExternalSecret` resources for approved tenant repositories

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

The chart also supports a top-level `tenantGitOps` block for shared tenant Argo CD onboarding.

## Tenant GitOps Model

This chart supports one shared tenant Argo CD instance.

Use it when:

- the admin team wants to keep the central platform Argo CD admin-only
- tenant teams need their own app continuous delivery flow
- tenant access must be approved during onboarding

Design rules:

- `platform/` and `workloads/` in this repo stay admin-only
- tenant teams do not get their own Argo CD instance
- tenant teams share one tenant Argo CD instance
- each tenant gets its own `AppProject`
- each tenant gets an approved repo allow-list
- each tenant gets an approved namespace allow-list
- `ApplicationSet` is allowed only when `allowApplicationSets: true`
- enabled tenant groups get namespace-scoped Kubernetes RBAC for Argo CD custom resources in their approved namespaces
- tenant repo credential secrets are created with `ExternalSecret`
- tenant repo credentials support the same HTTPS and SSH pattern used in the other factory repos
- tenant namespaces are added to the shared Argo CD instance only when the tenant is enabled

You can also tune the shared tenant Argo CD instance through `tenantGitOps.instance`, for example:

- server route enablement
- server, controller, repo-server, redis, and ApplicationSet resource requests and limits

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
- tenant repo credentials should use `ExternalSecret` and should point to the shared `ClusterSecretStore` name `platform-secrets` unless you intentionally override it
- the tenant Argo CD instance is disabled by default until an admin turns it on
- this design uses Argo CD "apps in any namespace"
- enabled tenant admin and deployer groups get namespace-scoped `Role` and `RoleBinding` objects so they can create `Application` objects in their approved namespaces
- `ApplicationSet` in any namespace is enabled only for tenants where `allowApplicationSets: true`
