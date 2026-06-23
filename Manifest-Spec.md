# Manifest Specification v1

## Overview

Every installed application in Acorn is represented by a manifest.

The UI acts as a visual editor for manifests.

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

## Schema

### apiVersion

Current value:

```yaml
acorn.dev/v1
```

### kind

Supported values:

```yaml
App
Stack
```

### metadata

```yaml
metadata:
  name: my-app
```

### spec

```yaml
spec:
  template: postgresql
```

### settings

User configurable values exposed through the UI.

```yaml
settings:
  port: 5432
```

## Storage

Manifests are stored internally in SQLite and can be exported or imported.

## Future

Future versions may support:

- Secrets
- Health checks
- Backups
- Resource limits
- Template versioning
