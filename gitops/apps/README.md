# GitOps Apps

This directory contains the Helm charts used by OpenShift GitOps.

Secret pattern:

- `external-secrets-operator` installs only the operator
- `external-secrets-config` is the place for the shared `ClusterSecretStore` and cluster-level ESO settings
- modules that need Kubernetes `Secret` objects must define the matching `ExternalSecret` resources in their own per-cluster values files
- engineers should add those `externalSecrets` entries before they enable the module in `gitops.yaml`
- `namespace-onboarding` also owns the shared tenant Argo CD onboarding pattern when admins enable it
- when tenant GitOps is enabled, `namespace-onboarding` also grants tenant groups namespace-scoped RBAC for `Application` and approved `ApplicationSet` objects

## Layout

- `platform/`: shared cluster services and policies
- `workloads/`: product or business workloads

## Platform Apps

- [self-provisioner](./platform/self-provisioner/README.md)
- [external-secrets-operator](./platform/external-secrets-operator/README.md)
- [external-secrets-config](./platform/external-secrets-config/README.md)
- [cert-manager-operator](./platform/cert-manager-operator/README.md)
- [cert-manager-config](./platform/cert-manager-config/README.md)
- [user-workload-monitoring](./platform/user-workload-monitoring/README.md)
- [internal-image-registry](./platform/internal-image-registry/README.md)
- [image-registry-allow-deny](./platform/image-registry-allow-deny/README.md)
- [global-cluster-pull-secret](./platform/global-cluster-pull-secret/README.md)
- [cluster-logging](./platform/cluster-logging/README.md)
- [splunk-log-forwarding](./platform/splunk-log-forwarding/README.md)
- [namespace-onboarding](./platform/namespace-onboarding/README.md)
- [identity-providers](./platform/identity-providers/README.md)
- [groups-rbac](./platform/groups-rbac/README.md)
- [vault-k8s-auth](./platform/vault-k8s-auth/README.md)
- [advanced-cluster-security-operator-bootstrap](./platform/advanced-cluster-security-operator-bootstrap/README.md)
- [compliance-operator](./platform/compliance-operator/README.md)
- [compliance-content](./platform/compliance-content/README.md)
- [file-integrity-operator-bootstrap](./platform/file-integrity-operator-bootstrap/README.md)
- [openshift-data-foundation-operator-bootstrap](./platform/openshift-data-foundation-operator-bootstrap/README.md)
- [openshift-pipelines-operator-bootstrap](./platform/openshift-pipelines-operator-bootstrap/README.md)
- [openshift-service-mesh-operator-bootstrap](./platform/openshift-service-mesh-operator-bootstrap/README.md)
- [openshift-virtualization-operator-bootstrap](./platform/openshift-virtualization-operator-bootstrap/README.md)
- [oadp-operator](./platform/oadp-operator/README.md)
- [oadp-backup](./platform/oadp-backup/README.md)
- [oadp-restore](./platform/oadp-restore/README.md)

## Workload Apps

- [cp4ba-operator](./workloads/cp4ba-operator/README.md)
- [aap](./workloads/aap/README.md)
- [openshift-ai](./workloads/openshift-ai/README.md)
