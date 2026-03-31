# OpenShift Virtualization Operator Bootstrap

Installs the OpenShift Virtualization operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

Default channel: `stable`
Default install plan approval: `Manual`

Keep it disabled until you have confirmed ROSA HCP support, worker instance type, and storage requirements for your target design.
