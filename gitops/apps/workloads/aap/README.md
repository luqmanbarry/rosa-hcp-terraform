# AAP

This chart installs Red Hat Ansible Automation Platform 2.6.

It does these jobs:

- creating a dedicated namespace
- installing the Ansible Automation Platform Operator
- creating an `AnsibleAutomationPlatform` custom resource

The defaults focus on the controller and aim to be a safer production baseline:

- `stable-2.6` operator channel
- `Manual` install plan approval so operator upgrades are explicitly controlled
- controller enabled, hub and EDA disabled by default
- resource requests and limits set for API, Redis, database, web, and task pods
- managed database storage requested
- `RECEPTOR_KUBE_SUPPORT_RECONNECT=enabled` set for controller execution environments, following Red Hat guidance for minimizing downtime during OpenShift upgrades

These defaults are a starting point, not a full customer design. Before enabling this in production, review:

- whether you want managed or external PostgreSQL
- backup and restore coverage for AAP CRs and database data
- namespace sizing and node placement
- route exposure and TLS model
- whether hub and EDA should remain disabled or be enabled in the same platform instance

Placement is optional by design:

- if `controller.node_selector` and `controller.postgres_selector` are empty, AAP schedules onto the default worker pool
- if you set those fields to labeled dedicated pools, AAP and its managed database are pinned to those nodes
