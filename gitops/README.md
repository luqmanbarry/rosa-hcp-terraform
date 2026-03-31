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

- choose apps in `clusters/<group-path>/<cluster>/gitops.yaml`
- set `enabled: true` only for the apps you want to run now
- put each app's values in `clusters/<group-path>/<cluster>/values/<app>.yaml`
- if an app needs a Kubernetes `Secret`, define its `externalSecrets` entries in that same values file before you enable the app

The sample clusters keep only `external-secrets-operator` enabled by default. All other modules are disabled until a user turns them on.

Platform modules in this repo include:

- self-provisioner
- external-secrets operator
- external-secrets config
- cert-manager operator
- cert-manager config
- user workload monitoring
- internal image registry
- image registry allow/deny
- global cluster pull secret
- cluster logging
- Splunk log forwarding
- namespace onboarding
- advanced cluster security operator bootstrap
- compliance operator
- compliance content
- file integrity operator bootstrap
- OpenShift Data Foundation operator bootstrap
- OpenShift Pipelines operator bootstrap
- OpenShift Service Mesh operator bootstrap
- OpenShift Virtualization operator bootstrap
- OADP operator
- OADP backup
- OADP restore
- identity providers
- groups and RBAC
- cost management
- workload identity service accounts
- Vault Kubernetes auth bootstrap

The central admin Argo CD in this repo is admin-only.

- it owns the platform repo
- it should deploy only admin-approved content from this repo
- tenant teams should use the shared tenant Argo CD path only after onboarding approval

Namespace rule:

- no chart should target the `default` namespace
- use an explicit platform namespace for admin apps
- let tenant-facing namespaces come from values or onboarding inputs

Workload modules in this repo include:

- `cp4ba-operator`
- `aap`
- `openshift-ai`
- `twistlock-defender-helm`

`twistlock-defender-helm` is an external Helm chart. Its values still live under `clusters/<group-path>/<cluster>/values/`.

Secrets should follow one simple rule:

- the module that needs a Kubernetes `Secret` should define the matching `ExternalSecret` in its own values file

Engineers should treat this as a deployment prerequisite:

- before enabling a module that needs secrets, make sure the shared `ClusterSecretStore` exists
- before enabling that module, add the matching `externalSecrets` entries to the same values file
- do not rely on a separate generic secrets chart to create those `Secret` objects later

Example:

- `identity-providers` should define the `ExternalSecret` objects for its OAuth client or LDAP bind secrets
- `user-workload-monitoring` should define the `ExternalSecret` for remote write credentials
- `cluster-logging` or `splunk-log-forwarding` should define the `ExternalSecret` for log forwarding tokens
- `oadp-operator` should define the `ExternalSecret` for backup credential secrets

This keeps the secret contract close to the module that uses it.

Workload identity follows a different split:

- Terraform creates IAM roles and trust policies
- GitOps creates service accounts with the `eks.amazonaws.com/role-arn` annotation
- both parts are opt-in

The default shared store name is `platform-secrets`.

For ROSA clusters, the default secret backend pattern in this repo is AWS Secrets Manager.

- use AWS Secrets Manager unless you have a clear reason to use a different provider
- keep the shared `ClusterSecretStore` name as `platform-secrets`
- let each secret-consuming module define its own `ExternalSecret` objects

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

The external-secrets-config module includes provider examples for:

- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- HashiCorp Vault
- IBM Cloud Secrets Manager
- CyberArk Conjur

The CyberArk example uses the ESO `conjur` provider name.

Those examples are for central `SecretStore` or `ClusterSecretStore` resources. Consumer modules should still define their own `ExternalSecret` resources in their per-cluster values files.

Tenant app CD uses a different pattern:

- `namespace-onboarding` can create one shared tenant Argo CD instance
- each tenant gets one `AppProject`
- each tenant gets approved namespaces and approved repos
- tenant admin and deployer groups get namespace-scoped RBAC for Argo CD custom resources in their approved namespaces
- tenant repo credentials are created with `ExternalSecret`
- `ApplicationSet` is disabled unless the admin enables it for that tenant

`compliance-operator` installs only the operator by default. No compliance profile is enabled until you add it.

For ROSA HCP:

- `compliance-operator` uses the HyperShift subscription config by default
- `file-integrity-operator-bootstrap` should stay disabled because Red Hat documents File Integrity Operator as unsupported on HCP clusters
- `file-integrity-operator-bootstrap` is the only module that still uses `set-before-enable`, and it should remain disabled on ROSA HCP
- foundational operator modules that other charts depend on use `Automatic` install plan approval so their CRDs are available early
- optional operator modules that do not act as shared prerequisites keep `Manual` approval by default
- current source-backed defaults in this repo include:
  - RHACS: `stable`
  - ODF: `stable-4.20`
  - OpenShift Pipelines: `latest`
  - OpenShift Service Mesh: `stable`
  - OpenShift Virtualization: `stable`
