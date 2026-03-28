# OpenShift Service Mesh Operator Bootstrap

Installs the OpenShift Service Mesh operator.

Use this module when you want GitOps to create the operator `OperatorGroup` and `Subscription`.

Keep it disabled until you set a real operator channel and have an approved service mesh design.

The sample values use `subscription_channel: set-before-enable` on purpose.
Replace it before you enable the module.
