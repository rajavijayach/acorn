# RFC-0003: Template System

## Status
Draft

## Goal
Define how curated application templates work.

## Principles

- Curated templates only in v0.1
- Templates define installation behavior
- Templates define UI settings

## Example

```yaml
name: PostgreSQL
image: postgres:17
```

## Responsibilities

Templates define:

- OCI image
- Environment variables
- Port mappings
- Volumes
- Installation form fields

## Future

Community templates may be supported in a future release.
