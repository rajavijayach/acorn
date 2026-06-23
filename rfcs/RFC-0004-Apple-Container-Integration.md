# RFC-0004: Apple Container Integration

## Status
Draft

## Goal
Define how Acorn interacts with Apple Container.

## Scope

Acorn is built specifically for Apple Container.

Runtime abstraction is intentionally out of scope.

## Integration Layer

Acorn invokes Apple Container commands through a runtime service.

Examples:

- container run
- container stop
- container logs
- container build

## Responsibilities

Runtime service:

- Execute commands
- Capture output
- Track status
- Surface errors

## Non Goals

- Docker support
- Podman support
- Kubernetes support
