# RFC-0003: Template System

## Status
Accepted

## Purpose
Templates define installation behavior and UI generation.

## Template Structure

```yaml
id: postgresql
name: PostgreSQL
category: Databases
image: postgres:17
```

## Required Fields

- id
- name
- category
- image
- settings

## Settings Definition

Supported types:
- string
- password
- integer
- boolean

## Runtime Definition

Templates define:
- image
- environment variables
- ports
- volumes

## Rendering

Template values may reference settings.

Example:

{{settings.username}}

## Distribution

v0.1 templates are bundled with the application.
