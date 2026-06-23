# RFC-0008: RuntimeService

## Status
Accepted

## Purpose
Define the boundary between Acorn and Apple Container.

## Rule

RuntimeService is the only component allowed to execute Apple Container commands.

## Public Interface

### Installation
- installApp(manifest)
- uninstallApp(appId)

### Lifecycle
- startApp(appId)
- stopApp(appId)
- restartApp(appId)

### Observability
- fetchLogs(appId)
- fetchStatus(appId)
- fetchResourceUsage(appId)

## Error Types
- runtimeUnavailable
- installFailed
- startFailed
- stopFailed
- invalidManifest

## Implementation

Version 1 uses Process APIs to invoke the container CLI.

No shell scripts are permitted.