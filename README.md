# Acorn 🌰

Run self-hosted apps on macOS using Apple's native Container runtime.

Acorn is an open-source native SwiftUI application built specifically for Apple Container. Instead of exposing container infrastructure, Acorn focuses on what users actually want: installing and running apps like PostgreSQL, Redis, Ollama, Open WebUI, and N8N.

## Why Acorn?

Most container tools are built for infrastructure engineers.

Acorn is built for people who want to:

- Run PostgreSQL locally
- Experiment with AI tools like Ollama and Open WebUI
- Launch automation tools like N8N
- Use Apple's native container stack without learning CLI commands

Containers are an implementation detail.

## Current Status

Acorn is under active development.

Implemented:

- Native macOS SwiftUI application
- Apple Container detection and version checks
- SQLite persistence layer
- Manifest rendering engine
- Template loading system
- Discover catalog
- PostgreSQL template

In Progress:

- PostgreSQL installation workflow
- Runtime execution layer
- Installed apps dashboard

## Product Principles

### Apps First

Users install apps.

Users do not manage containers.

### Native macOS Experience

Built with SwiftUI and designed to feel at home on macOS.

### Apple Container Only

Acorn is intentionally built for Apple Container.

No runtime abstraction layer.

### Transparent Architecture

Every installed app is backed by a manifest that can be inspected, exported, and shared.

## Planned Apps

### AI

- Ollama
- Open WebUI

### Databases

- PostgreSQL
- Redis

### Automation

- N8N

## Architecture

```text
SwiftUI
    ↓
Features
    ↓
Core Services
    ↓
SQLite
    ↓
Manifest Engine
    ↓
RuntimeService
    ↓
Apple Container
```

## Documentation

- Vision.md
- Manifest-Spec.md
- Template-Spec.md
- docs/
- rfcs/

## Contributing

Please read CONTRIBUTING.md before submitting changes.

Documentation, templates, bug fixes, and feedback are all welcome.

## License

TBD
