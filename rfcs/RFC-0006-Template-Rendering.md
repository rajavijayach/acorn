# RFC-0006: Template Rendering

## Status
Accepted

## Purpose
Define how templates become manifests and runtime configuration.

## Flow

Template
→ User Input
→ Rendered Manifest
→ Runtime Execution

## Variable Syntax

Templates may reference user settings.

Example:

```text
{{settings.username}}
```

## Rendering Rules

- Missing required values fail validation
- Unknown variables fail rendering
- Rendered manifests must be deterministic

## Example

Template:

```yaml
env:
  POSTGRES_USER: "{{settings.username}}"
```

Input:

```yaml
username: postgres
```

Output:

```yaml
env:
  POSTGRES_USER: postgres
```

## Validation Stages

1. Template validation
2. User input validation
3. Manifest validation
4. Runtime validation
