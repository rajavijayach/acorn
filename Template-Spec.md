# Template Specification v1

## Overview

Templates define how apps are installed and managed.

Users interact with manifests.

Contributors create templates.

## Example

```yaml
name: PostgreSQL
category: Databases

image: postgres:17

settings:
  username:
    type: string
    default: postgres

  password:
    type: password

  port:
    type: integer
    default: 5432

env:
  POSTGRES_USER: "{{settings.username}}"
  POSTGRES_PASSWORD: "{{settings.password}}"

ports:
  - host: "{{settings.port}}"
    container: 5432
```

## Required Fields

### name

Display name.

### category

Examples:

- AI
- Databases
- Automation
- Development
- Monitoring

### image

OCI image reference.

### settings

Fields shown to users in the installation UI.

## Goals

- Human readable
- Easy contribution workflow
- No Swift knowledge required

## Initial Official Templates

- PostgreSQL
- Redis
- Ollama
- Open WebUI
- N8N
