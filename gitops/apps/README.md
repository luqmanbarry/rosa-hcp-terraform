# GitOps Apps

This directory contains the Helm charts used by OpenShift GitOps.

## Layout

- `platform/`: shared cluster services and policies
- `workloads/`: product or business workloads

## Platform Apps

- [self-provisioner](./platform/self-provisioner/README.md)
- [external-secrets-operator](./platform/external-secrets-operator/README.md)
- [cert-manager-operator](./platform/cert-manager-operator/README.md)
- [user-workload-monitoring](./platform/user-workload-monitoring/README.md)
- [internal-image-registry](./platform/internal-image-registry/README.md)
- [image-registry-allow-deny](./platform/image-registry-allow-deny/README.md)
- [cluster-logging](./platform/cluster-logging/README.md)
- [namespace-onboarding](./platform/namespace-onboarding/README.md)
- [identity-providers](./platform/identity-providers/README.md)
- [groups-rbac](./platform/groups-rbac/README.md)
- [vault-k8s-auth](./platform/vault-k8s-auth/README.md)
- [compliance-operator](./platform/compliance-operator/README.md)
- [oadp-operator](./platform/oadp-operator/README.md)
- [oadp-backup](./platform/oadp-backup/README.md)
- [oadp-restore](./platform/oadp-restore/README.md)

## Workload Apps

- [cp4ba-operator](./workloads/cp4ba-operator/README.md)
- [aap](./workloads/aap/README.md)
- [openshift-ai](./workloads/openshift-ai/README.md)
