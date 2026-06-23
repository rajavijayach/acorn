# Acorn

The easiest way to run self-hosted apps on macOS using Apple's Container runtime.

Acorn is a native SwiftUI application built specifically for Apple Container. It focuses on installing and managing apps such as PostgreSQL, Redis, Ollama, Open WebUI, and N8N through a simple desktop experience.

## Goals

- Native macOS experience
- Built specifically for Apple Container
- App-first UX, not container-first UX
- Open source
- Manifest-driven architecture

## Non-Goals

- Kubernetes
- Multi-host orchestration
- Runtime abstraction layers
- Docker replacement
- Cloud control plane

## Initial Apps

- PostgreSQL
- Redis
- Ollama
- Open WebUI
- N8N

## Architecture

SwiftUI App
→ SQLite
→ Manifest Engine
→ Apple Container CLI

## License

TBD
