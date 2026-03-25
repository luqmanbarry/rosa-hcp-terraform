# self-provisioner

Controls whether authenticated users can self-provision new projects.

## Default

- self-provisioning disabled
- project request message shown to users

## Use

Enable only where self-service namespace creation is appropriate.

If self-service project creation is enabled, `projectRequestTemplateName` can point the cluster-wide project request flow at a template created by the `namespace-onboarding` chart.
