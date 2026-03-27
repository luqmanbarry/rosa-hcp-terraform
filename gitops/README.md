# GitOps

OpenShift GitOps owns normal cluster configuration after Terraform finishes bootstrap.

Simple flow:

1. Terraform bootstraps the OpenShift GitOps operator and seeds a root `Application`.
2. The root application points to the shared overlay under `gitops/overlays/cluster-applications/`.
3. The shared overlay creates child Argo CD applications.
4. Those child applications deploy platform and workload modules.

Most reusable apps in this repo are Helm charts.

The shared overlay is a Helm chart. Terraform injects the real Git repository URL and Git revision into it during bootstrap.

How to configure GitOps for one cluster:

- choose apps in `clusters/<environment>/<cluster>/gitops.yaml`
- set `enabled: true` only for the apps you want to run now
- put each app's values in `clusters/<environment>/<cluster>/values/<app>.yaml`

The sample clusters keep only `external-secrets-operator` enabled by default. All other modules are disabled until a user turns them on.

Platform modules in this repo include:

- self-provisioner
- external-secrets operator
- cert-manager operator
- user workload monitoring
- internal image registry
- image registry allow/deny
- cluster logging
- Splunk log forwarding
- namespace onboarding
- compliance operator
- OADP operator
- OADP backup
- OADP restore
- identity providers
- groups and RBAC
- Vault Kubernetes auth bootstrap

Workload modules in this repo include:

- `cp4ba-operator`
- `aap`
- `openshift-ai`
- `twistlock-defender-helm`

`twistlock-defender-helm` is an external Helm chart. Its values still live under `clusters/<environment>/<cluster>/values/`.

Secrets should follow one simple rule:

- the module that needs a Kubernetes `Secret` should define the matching `ExternalSecret` in its own values file

Example:

- `identity-providers` should define the `ExternalSecret` objects for its OAuth client or LDAP bind secrets
- `user-workload-monitoring` should define the `ExternalSecret` for remote write credentials
- `cluster-logging` or `splunk-log-forwarding` should define the `ExternalSecret` for log forwarding tokens
- `oadp-operator` should define the `ExternalSecret` for backup credential secrets

This keeps the secret contract close to the module that uses it.

`oadp-backup` and `oadp-restore` stay separate on purpose:

- `oadp-backup` is steady-state policy
- `oadp-restore` is an operational recovery action

They are different kinds of operations, so they should not share the same module.

The `user-workload-monitoring` chart owns both:

- `cluster-monitoring-config` in `openshift-monitoring`
- `user-workload-monitoring-config` in `openshift-user-workload-monitoring`

This avoids Argo CD ownership conflicts.

`external-secrets-operator` and `cert-manager-operator` should run early:

- `external-secrets-operator` should come before modules that expect secrets sourced from an external backend
- `cert-manager-operator` should come before modules that rely on declarative certificate issuance

`compliance-operator` installs only the operator by default. No compliance profile is enabled until you add it.
