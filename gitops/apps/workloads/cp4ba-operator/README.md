# CP4BA Operator

This chart installs the IBM Cloud Pak for Business Automation operator with namespace-scoped defaults for production use.

Default behavior:

- installs into a dedicated namespace
- uses the `v24.0` channel for CP4BA 24.x
- uses `Manual` install plan approval
- installs with a namespace-scoped `OperatorGroup`
- references the IBM `ibm-cp4a-operator-catalog` in `openshift-marketplace`

These defaults follow IBM guidance to use a dedicated namespace for CP4BA production deployments and to avoid cluster-scoped foundational services for new production installs.

Before enabling this chart, make sure:

- the required IBM catalogs are available on the cluster
- the target namespace is new and does not already contain Cloud Pak foundational services from another deployment
- the image registry allowlist includes IBM registries such as `cp.icr.io` and `icr.io`
