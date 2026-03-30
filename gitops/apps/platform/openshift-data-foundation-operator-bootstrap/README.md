# OpenShift Data Foundation Operator Bootstrap

Installs the OpenShift Data Foundation operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

Default channel: `stable-4.20`

Keep it disabled until you have a storage design for the cluster.

The default channel follows the repo's current OpenShift 4.20 cluster baseline. If you move the repo to a different OpenShift minor version, update this channel to the matching ODF stable channel.
