# OpenShift Data Foundation Operator Bootstrap

Installs the OpenShift Data Foundation operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

Keep it disabled until you set a real operator channel and have a storage design for the cluster.

The sample values use `subscription_channel: set-before-enable` on purpose.
Replace it before you enable the module.
