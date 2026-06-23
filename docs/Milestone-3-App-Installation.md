# Milestone 3: App Installation

## Goal

Deliver the first complete end-to-end application installation experience.

The sole target for this milestone is PostgreSQL.

A user should be able to discover, configure, install, and run PostgreSQL entirely through Acorn.

---

## Success Criteria

A user can:

1. Open Acorn
2. Open Discover
3. Select PostgreSQL
4. Configure installation settings
5. Click Install
6. Acorn generates a manifest
7. Acorn launches PostgreSQL using Apple Container
8. PostgreSQL appears in Home
9. Status shows Running

---

## Priority 1: Manifest Rendering

References:

- RFC-0002-Manifest-Format.md
- RFC-0006-Template-Rendering.md

### Scope

Implement rendering from template + user settings into a concrete manifest.

### Flow

Template
→ User Settings
→ Manifest

### Requirements

- Deterministic rendering
- Validation before persistence
- Manifest stored in SQLite

### Acceptance Criteria

- PostgreSQL manifest generated successfully
- Manifest persisted successfully

---

## Priority 2: PostgreSQL Install Flow

### Screen Flow

Discover
→ PostgreSQL
→ Configure
→ Review
→ Install

### Configuration Fields

- Username
- Password
- Port

### Requirements

- SwiftUI form
- Validation
- Review screen before install

### Acceptance Criteria

- User can complete install wizard

---

## Priority 3: Runtime Execution

Reference:

- RFC-0008-RuntimeService.md

### RuntimeService Additions

```swift
func installApp(manifest: AppManifest)
func uninstallApp(appId: UUID)
```

### Responsibilities

- Generate runtime command
- Execute installation
- Capture output
- Surface failures

### Acceptance Criteria

- PostgreSQL container starts successfully

---

## Priority 4: Installation Lifecycle

Reference:

- RFC-0007-App-Installation-Lifecycle.md

### Status Flow

installing
↓
running

Failure path:

installing
↓
failed

### Requirements

- Persist status changes
- Surface errors in UI

---

## Priority 5: Home Screen Integration

### Scope

Display installed applications from SQLite.

### Sections

Running
Installed

### Acceptance Criteria

- PostgreSQL appears after installation
- Status updates correctly

---

## Deliverables

- Manifest renderer
- PostgreSQL installation wizard
- RuntimeService installation support
- Installation lifecycle implementation
- Home screen backed by installed_apps table
- First successful PostgreSQL deployment

---

## Out of Scope

- Redis installation
- Ollama installation
- N8N installation
- Open WebUI installation
- Log streaming
- Resource monitoring
- Backup and restore
- Community templates

These belong to later milestones.

---

## Definition of Done

A fresh user can install PostgreSQL from the Acorn UI and see a running application in Home without using Terminal.