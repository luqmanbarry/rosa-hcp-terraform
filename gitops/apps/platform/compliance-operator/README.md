# compliance-operator

Installs the OpenShift Compliance Operator.

## Default

- installs the Operator in `openshift-compliance`
- uses the OLM `Subscription` and `OperatorGroup` APIs that current OpenShift uses
- uses the `stable` channel by default
- uses `Manual` install plan approval by default
- sets `PLATFORM=HyperShift` in the subscription config for ROSA HCP
- does not enable any compliance profile or scan by default
- optional `ScanSetting` and `ScanSettingBinding` objects can be supplied later through values

## Why No Profiles By Default

The Compliance Operator ships with profile content, but scans should not start automatically in a reusable factory without an explicit decision on:

- which profile to use
- when to scan
- where to store results
- whether remediations should be auto-applied

This keeps the default setup safe and predictable.

## Notes

- Operator installation uses `operators.coreos.com/v1alpha1` for `Subscription` and `operators.coreos.com/v1` for `OperatorGroup`.
- `scanSettingBindings` is empty by default, so no profile is enabled automatically.
