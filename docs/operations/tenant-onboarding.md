# Tenant Onboarding

This document explains the tenant Argo CD model in this repo.

## Admin And Tenant Boundary

Admin-owned:

- the central GitOps bootstrap
- all apps under `gitops/apps/platform/`
- all apps under `gitops/apps/workloads/`
- cluster-wide policy and platform configuration
- onboarding approval
- tenant repo approval
- tenant namespace approval

Tenant-owned after approval:

- Argo CD `Application` objects in the shared tenant Argo CD instance
- optional `ApplicationSet` objects when the admin enables them for that tenant
- app-of-apps patterns inside the tenant's approved repositories
- Kubernetes `Role` and `RoleBinding` access in their approved namespaces for those Argo CD custom resources

## Argo CD Layout

This repo uses two Argo CD layers:

1. Central admin Argo CD
   - bootstrapped by Terraform
   - admin-only
   - targets only this platform repo

2. Shared tenant Argo CD
   - created by the onboarding chart only when enabled
   - shared by many teams
   - one `AppProject` per tenant
   - each tenant is limited to approved namespaces and approved repos
   - enabled tenant namespaces are added to the shared Argo CD instance for `Application` creation
   - `ApplicationSet` namespaces are added only for tenants that are explicitly approved

## Approval Flow

1. Admin reviews the tenant request.
2. Admin adds tenant namespaces and optional guardrails.
3. Admin enables `tenantGitOps` if needed.
4. Admin adds a tenant definition with:
   - approved namespaces
   - approved repo URLs
   - approved groups
   - optional `ApplicationSet` approval
   - repo credential `ExternalSecret` definitions
5. Admin merges the change.
6. Tenant users can then use the shared tenant Argo CD instance.

After approval:

- tenant users can create `Application` objects in their approved namespaces
- tenant admin and deployer groups get namespace-scoped Kubernetes RBAC for those `Application` objects
- tenant users can use app-of-apps in their approved repos
- tenant users can create `ApplicationSet` objects only if `allowApplicationSets: true`
- tenant users do not get access to the central admin Argo CD instance

## Namespace Guardrails

Guardrails are optional and can be set per namespace:

- `ResourceQuota`
- `LimitRange`
- baseline `NetworkPolicy`

They are not forced on unless the admin adds them.

## Repo Credentials

Tenant repo credentials live in the shared tenant Argo CD namespace.

Rules:

- use `ExternalSecret`
- do not store plaintext credentials in Git
- keep HashiCorp Vault as the default example pattern
- other providers are examples only
- every repo credential must match an approved repo URL for that tenant
- repo credentials can use HTTPS username/password or SSH private key, based on the approved repo access method

## ApplicationSet

`ApplicationSet` is disabled by default for tenants.

Allow it only when:

- the tenant needs app-of-apps or generator-based app management
- the tenant repo and namespace boundaries are already approved
- the admin accepts the extra governance risk

This repo keeps `platform/` and `workloads/` admin-only even when tenant GitOps is enabled.
