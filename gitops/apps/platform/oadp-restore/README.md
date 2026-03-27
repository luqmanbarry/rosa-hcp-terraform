# OADP Restore

This chart manages restore actions.

Keep it separate from backup schedules because restore is an operational event, not a normal always-on policy.

## Recommended Usage

- disabled by default
- enabled only for restore drills, migration tests, or incidents
- reviewed and approved like an operational change

## Values

- `enabled`: master toggle
- `storageClassMapping`: optional storage class remapping
- `restores`: list of restore objects

Each restore supports:

- `name`
- `backupName`
- `includedNamespaces`
- `namespaceMapping`
- `restorePVs`
