# OpenShift Virtualization Operator Bootstrap

Installs the OpenShift Virtualization operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

Keep it disabled until you set a real operator channel and have approved worker pool and storage settings for virtualization.

The sample values use `subscription_channel: set-before-enable` on purpose.
Replace it before you enable the module.
