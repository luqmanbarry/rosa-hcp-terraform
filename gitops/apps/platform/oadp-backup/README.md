# OADP Backup

This chart manages normal backup schedules.

Use it for:

- recurring scheduled protection
- environment baseline backup policy
- namespace-level backup selection

Do not use it for restore drills or incident recovery actions.

## Recommended Usage

- `dev`: optional, usually disabled
- `qa`: enabled for rehearsal and validation
- `prod`: enabled
- `prod-dr`: enabled where appropriate for DR verification

## Backup Modes

- `filesystem`: pod volume backup via file system backup
- `snapshot`: CSI snapshot-based backup with `snapshotMoveData`

## Values

- `enabled`: master toggle
- `backupMode`: `filesystem` or `snapshot`
- `includeClusterResources`: default cluster resource inclusion behavior
- `schedules`: list of schedule objects

Each schedule supports:

- `name`
- `cronSchedule`
- `backupRetentionPeriod`
- `includedNamespaces`
- `excludedNamespaces`
- `paused`
- `storageLocation`
- `includeClusterResources`
- `csiSnapshotTimeout`
