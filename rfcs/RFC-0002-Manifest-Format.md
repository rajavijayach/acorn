# RFC-0002: Manifest Format

## Status
Accepted

## Schema Version

apiVersion: acorn.dev/v1

## Top Level Structure

```yaml
apiVersion: acorn.dev/v1
kind: App
metadata:
  name: postgres
spec:
  template: postgresql
  settings: {}
```

## Required Fields

### apiVersion
String.

### kind
Supported:
- App

### metadata.name
Unique app name.

### spec.template
Template identifier.

### spec.settings
Key-value settings provided by users.

## Validation Rules

- name must be unique
- template must exist
- settings keys must match template definition

## Storage

Stored in SQLite as YAML text.

## Export

Exports must preserve exact schema version.
