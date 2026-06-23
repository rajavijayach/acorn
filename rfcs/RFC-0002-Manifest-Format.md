# RFC-0002: Manifest Format

## Status
Draft

## Goal
Define the manifest schema used internally by Acorn.

## Example

```yaml
apiVersion: acorn.dev/v1
kind: App

metadata:
  name: postgres

spec:
  template: postgresql

  settings:
    username: postgres
    password: secret
    port: 5432
```

## Requirements

- Human readable
- Exportable
- Importable
- Versioned

## Storage

Stored internally in SQLite.
