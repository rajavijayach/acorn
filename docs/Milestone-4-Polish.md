# Milestone 4: Polish the First App Experience

## Goal

Make PostgreSQL production-quality before adding a second app.

If PostgreSQL feels amazing, every future app inherits that quality.

This milestone deliberately deepens the single-app experience rather than
widening the catalog. The catalog grows in Milestone 5.

---

## Success Criteria

A user can:

1. Click an installed app in Home and open a details page
2. View live logs for a running app
3. Start, stop, and restart an app without reinstalling
4. Delete an app with explicit control over its data
5. See real connection details and copy a connection string
6. Launch Acorn for the first time and get a friendly, guided setup
7. See meaningful health status instead of a bare "Running"
8. Copy a diagnostics report from Settings for support

---

## Priority 1: App Details

Currently Home shows the app.

Clicking it should open a details page with tabs:

```text
PostgreSQL

Overview
Logs
Manifest
```

Overview shows:

- Status
- Template version
- Created date
- Port
- Username
- Data location

### Acceptance Criteria

- Every installed app has a details page.

---

## Priority 2: Logs

One of the biggest missing pieces today.

```text
PostgreSQL

Overview
Logs
Manifest
```

Logs:

- live tail
- auto-scroll
- pause
- copy
- clear

No filtering yet.

This will dramatically improve troubleshooting.

### Acceptance Criteria

- Logs stream live for a running app.

---

## Priority 3: Start / Stop / Restart

Instead of requiring reinstall.

Buttons:

```text
Start
Stop
Restart
```

### RuntimeService Additions

```swift
func startApp(appID: UUID)
func stopApp(appID: UUID)
func restartApp(appID: UUID)
```

### Acceptance Criteria

- Status updates correctly without reinstalling.

---

## Priority 4: Delete

This is more important than it sounds.

Deleting a database should never accidentally delete data.

Flow:

```text
Delete PostgreSQL?

☑ Keep Data

Delete
Cancel
```

Later, separate these concepts explicitly:

```text
Delete App
Delete Everything
```

### Acceptance Criteria

- Deleting an app never removes its data unless the user opts in.

---

## Priority 5: Connection Details

Instead of:

```text
Running
```

show:

```text
Host       localhost
Port       5432
Database   postgres
Username   postgres
Password   ********
```

Buttons:

```text
Copy Connection String
Reveal Manifest
```

This makes Acorn genuinely useful.

### Acceptance Criteria

- Connection details are shown and the connection string can be copied.

---

## Priority 6: Better First Launch

The only item adopted from the early feedback immediately.

Current:

```text
Apple Container:
Not Installed
```

Instead:

```text
Welcome to Acorn

✓ Apple Silicon
✓ macOS Compatible
⚠ Apple Container Missing

Install
Learn More
```

If installed:

```text
✓ Ready

Browse Apps
```

This is much friendlier.

### Acceptance Criteria

- First launch presents a guided, readable readiness screen.

---

## Priority 7: App Health

Instead of only:

```text
Running
```

show meaningful health:

```text
● Healthy
● Starting
● Failed
```

Eventually:

```text
Last Started
Restart Count
Uptime
```

These are much more meaningful than just "running."

### Acceptance Criteria

- Apps surface a health state beyond a binary running flag.

---

## Priority 8: Diagnostics

Acorn is now mature enough to start building developer trust.

Add a simple diagnostics screen in Settings:

```text
Settings

Diagnostics

✓ Apple Silicon
✓ macOS Version
✓ Apple Container Version
✓ Runtime Available
Database
Templates

Copy Diagnostics
```

When someone opens a GitHub issue, they can click **Copy Diagnostics** and
paste the result into the issue. This will save significant support time as
more users try Acorn.

### Acceptance Criteria

- A diagnostics report can be copied from Settings in one click.

---

## Deliverables

- App details page with Overview / Logs / Manifest tabs
- Live log streaming
- Start / stop / restart support in RuntimeService
- Safe delete flow with data retention control
- Connection details with copyable connection string
- Guided first-launch experience
- App health status
- Settings diagnostics screen

---

## Out of Scope (Postponed)

These are interesting but premature for where Acorn is today.

- **Menu Bar companion** — users will spend most of their time in the app initially.
- **Notifications** — no long-running operations yet to notify about.
- **Remote catalog** — curated templates are an intentional choice; keep it.
- **AI model downloads** — Ollama isn't in the product yet.
- **Community manifests** — the manifest spec isn't stabilized yet.

---

## Definition of Done

PostgreSQL feels production-quality: a user can inspect, operate, troubleshoot,
connect to, and safely remove it entirely from the Acorn UI, with a friendly
first launch and copyable diagnostics for support.

---

## Next: Milestone 5

Only after Milestone 4 is finished, widen the catalog. Each should mostly be
template work if the architecture is holding up:

```text
Redis
Ollama
Open WebUI
```
