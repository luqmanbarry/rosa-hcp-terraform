# File Integrity Operator Bootstrap

Installs the File Integrity Operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

Do not enable this module on ROSA HCP.

Red Hat documents that File Integrity Operator is not supported on HCP clusters.

The sample values use `subscription_channel: set-before-enable` on purpose.
Replace it before you enable the module.
