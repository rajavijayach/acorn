# RFC-0001: App Model

## Status
Accepted

## Purpose
Define the core domain entities used throughout Acorn.

## Domain Model

### AppTemplate
Read-only curated blueprint shipped with Acorn.

Fields:
- id
- name
- category
- icon
- templateVersion
- templateDefinition

### AppManifest
User configuration generated from a template.

Fields:
- id
- appId
- schemaVersion
- manifestYaml
- createdAt
- updatedAt

### InstalledApp
Represents an installed application.

Fields:
- id
- name
- templateId
- status
- manifestId
- createdAt
- updatedAt

## Status Values

- installing
- running
- stopped
- failed
- deleting

## Lifecycle

Template -> Manifest -> InstalledApp

## Resource Ownership

Each InstalledApp owns:
- One manifest
- One primary container
- Zero or more volumes

## Persistence

InstalledApp records are stored in SQLite.

Manifests are stored as versioned YAML blobs.
