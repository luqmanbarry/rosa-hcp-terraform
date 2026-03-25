# GitOps

OpenShift GitOps owns day-2 cluster configuration in this repository.

The intended model is:

1. Terraform bootstraps the OpenShift GitOps operator and seeds a root `Application`.
2. The root application points to an environment overlay under `gitops/overlays/`.
3. The overlay deploys a curated set of platform applications using an App-of-Apps pattern.

Reusable platform applications should generally be packaged as Helm charts. Environment-specific composition and small patches should use Kustomize overlays.

The environment overlays under `gitops/overlays/` are implemented as Helm charts so the root application can inject the actual Git repository URL and target revision at bootstrap time.

The initial platform baseline implemented here includes:

- self-provisioner
- user workload monitoring
- internal image registry
- image registry allow/deny
- cluster logging
- namespace onboarding
- OADP operator
- OADP backup
- OADP restore
- identity providers
- groups and RBAC
- Vault Kubernetes auth bootstrap

Workload-specific charts can live under `gitops/apps/workloads/`. The initial workload examples are:

- `cp4ba-operator`, which installs the IBM CP4BA operator with namespace-scoped `v24.0` defaults aligned to IBM production guidance
- `aap`, which installs Red Hat Ansible Automation Platform 2.6 using the `AnsibleAutomationPlatform` CR with controller-focused production defaults
- `openshift-ai`, which installs Red Hat OpenShift AI Self-Managed with `DSCInitialization`, `DataScienceCluster`, and dashboard settings that expose hardware profiles for AI node targeting

`oadp-backup` and `oadp-restore` remain separate by design:

- `oadp-backup` is steady-state policy
- `oadp-restore` is an operational recovery action

They should not share ownership because their risk profile and lifecycle are different.

The `user-workload-monitoring` chart owns both:

- `cluster-monitoring-config` in `openshift-monitoring`
- `user-workload-monitoring-config` in `openshift-user-workload-monitoring`

This matches the current OpenShift monitoring model more closely and avoids Argo CD ownership conflicts.
