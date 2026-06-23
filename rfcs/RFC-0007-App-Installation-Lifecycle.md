# RFC-0007: App Installation Lifecycle

## Status
Accepted

## Purpose
Define the complete installation flow.

## Installation Sequence

1. User selects app
2. Template loaded
3. Configuration form rendered
4. User submits settings
5. Template rendered into manifest
6. Manifest stored in SQLite
7. RuntimeService executes installation
8. InstalledApp record created
9. Status changes to running

## Failure Handling

Any failure must:

- Capture error details
- Create event record
- Surface user-friendly message
- Leave database in a consistent state

## Status Transitions

```text
installing
  ↓
running
  ↓
stopped
```

Failure path:

```text
installing
  ↓
failed
```

## Deletion Sequence

1. Stop runtime resources
2. Delete runtime resources
3. Delete manifest
4. Delete InstalledApp record
5. Record event

## Success Criteria

An installation is successful only when:

- Runtime resources exist
- App is reachable
- Status is running
