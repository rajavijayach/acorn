# Milestone 2: Foundation Layer

## Goal

Build the core platform services that will power app installation, storage, and runtime integration.

This milestone intentionally avoids implementing full app installation.

The focus is creating a solid foundation.

---

## Success Criteria

At the end of this milestone Acorn should:

- Detect Apple Container
- Report Apple Container version
- Persist data using SQLite
- Load bundled templates
- Display a real Discover catalog
- Have a clean service architecture

---

## Priority 1: RuntimeService

Reference:

- RFC-0008-RuntimeService.md

### Scope

Implement the initial RuntimeService.

### Public Interface

```swift
protocol RuntimeService {
    func isInstalled() async -> Bool
    func version() async -> String?
}
```

### Requirements

- Use Process APIs
- No shell scripts
- No direct CLI calls from SwiftUI views
- RuntimeService is the only runtime integration layer

### Acceptance Criteria

- Detect container CLI availability
- Return runtime version
- Handle missing runtime gracefully

---

## Priority 2: SQLite Storage Layer

Reference:

- RFC-0005-SQLite-Schema.md

### Initial Tables

Implement only:

- installed_apps
- manifests

Skip:

- events
- templates

for this milestone.

### Requirements

- SQLite only
- Repository pattern
- Migration support

### Acceptance Criteria

- Database initializes on launch
- Tables created automatically
- Read/write operations verified

---

## Priority 3: Core Models

### Models

```swift
InstalledApp
AppManifest
AppStatus
```

### Requirements

- Codable
- Testable
- Independent of SwiftUI

---

## Priority 4: Template Loader

Reference:

- RFC-0003-Template-System.md
- RFC-0006-Template-Rendering.md

### Scope

Load bundled templates from:

```text
Resources/Templates
```

### Initial Template

```text
postgresql.yaml
```

### Acceptance Criteria

- Template loads successfully
- Template validates successfully
- Template metadata available to UI

---

## Priority 5: Discover Screen

Replace placeholder content.

### Initial Catalog

#### AI

- Ollama
- Open WebUI

#### Databases

- PostgreSQL
- Redis

#### Automation

- N8N

### Acceptance Criteria

- Apps displayed in categories
- Metadata loaded from templates
- UI prepared for future install flow

---

## Suggested Project Structure

```text
Acorn
├── App
├── Features
│   ├── Home
│   ├── Discover
│   ├── AppDetails
│   └── Settings
├── Core
│   ├── Runtime
│   ├── Storage
│   ├── Templates
│   └── Models
├── Resources
│   └── Templates
└── Tests
```

---

## Deliverables

- RuntimeService implemented
- SQLite initialized
- Core models created
- Template loader implemented
- PostgreSQL template added
- Discover screen backed by template metadata

---

## Out of Scope

- App installation
- App deletion
- Manifest rendering
- Container execution
- Log streaming
- Resource monitoring
- Community templates

These belong to Milestone 3.