# Architecture

## Overview

Acorn is a native SwiftUI application built specifically for Apple Container.

Users interact with apps.

Apple Container remains an implementation detail.

## High Level Architecture

```text
SwiftUI
  ↓
Application Layer
  ↓
SQLite
  ↓
Manifest Engine
  ↓
Apple Container CLI
```

## Components

### UI Layer

- Home
- Discover
- Install Wizard
- App Details
- Logs

### Application Layer

- App Management
- Template Rendering
- Manifest Generation
- Runtime Operations

### Storage Layer

SQLite database.

Stores:

- Installed apps
- Manifests
- Templates
- Events

### Runtime Layer

Wrapper around Apple Container CLI commands.

Examples:

- container run
- container stop
- container logs

## Design Goals

- Native
- Simple
- Offline first
- App focused
- Open source
