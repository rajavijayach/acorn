# RFC-0001: App Model

## Status
Draft

## Purpose
Define the core domain model used by Acorn.

## Concepts

### AppTemplate
A curated blueprint maintained by Acorn.

Examples:
- PostgreSQL
- Redis
- Ollama
- Open WebUI
- N8N

### AppManifest
User-specific configuration generated from a template.

### InstalledApp
A deployed application managed by Acorn.

## Lifecycle

Template -> Manifest -> Installed App

## Design Rules

- Users install apps, not containers
- Templates are curated in v0.1
- One InstalledApp maps to one manifest
