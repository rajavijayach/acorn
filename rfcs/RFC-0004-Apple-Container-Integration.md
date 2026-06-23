# RFC-0004: Apple Container Integration

## Status
Accepted

## Purpose
Define runtime integration with Apple Container.

## Runtime Service

The RuntimeService is the only component allowed to invoke the container CLI.

## Responsibilities

- Install detection
- Command execution
- Log collection
- Status collection
- Error handling

## Supported Commands

- container run
- container stop
- container start
- container logs
- container ps

## Error Model

Runtime errors must be normalized into:

- installationFailed
- startupFailed
- stopFailed
- runtimeUnavailable

## Non Goals

- Docker compatibility
- Podman compatibility
- Runtime abstraction layers

## Future

Additional Apple Container capabilities may be surfaced as native Acorn features.
