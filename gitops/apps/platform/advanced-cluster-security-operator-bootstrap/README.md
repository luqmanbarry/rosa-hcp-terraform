# Advanced Cluster Security Operator Bootstrap

Installs the Red Hat Advanced Cluster Security operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

Keep it disabled until you set a real operator channel in the cluster values file.

The sample values use `subscription_channel: set-before-enable` on purpose.
Replace it before you enable the module.
