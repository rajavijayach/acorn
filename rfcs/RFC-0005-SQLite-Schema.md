# RFC-0005: SQLite Schema

## Status
Accepted

## Purpose
Define the persistent storage model for Acorn.

## Database

SQLite is the only database used by Acorn.

## Tables

### installed_apps

```sql
CREATE TABLE installed_apps (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  template_id TEXT NOT NULL,
  status TEXT NOT NULL,
  manifest_id TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### manifests

```sql
CREATE TABLE manifests (
  id TEXT PRIMARY KEY,
  app_id TEXT NOT NULL,
  schema_version TEXT NOT NULL,
  manifest_yaml TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### templates

```sql
CREATE TABLE templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  version TEXT NOT NULL
);
```

### events

```sql
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  app_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  payload TEXT,
  created_at DATETIME NOT NULL
);
```

## Design Principles

- Manifest is source of truth
- SQLite is implementation detail
- Migrations must be forward compatible
