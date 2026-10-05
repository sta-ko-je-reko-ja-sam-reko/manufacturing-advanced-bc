# FEAT-CORE-001 - Foundation

Integration test plan. The foundation posts nothing, so its integration cases are about installation and
the client session, which the AL test runner cannot drive.

## TEST-01 — Installation registers the guided setup
- **Given** a company where the app has never been installed
- **When** the app is installed
- **Then** *Assisted Setup* lists *Set up Manufacturing Advanced*, and *Manufacturing advanced setup* opens with no error

**Automation:** manual, on `bc29loc`

## TEST-02 — Upgrade is idempotent
- **Given** the app installed
- **When** the same version is republished and upgraded
- **Then** there is still one assisted setup entry and one foundation record

**Automation:** manual, on `bc29loc`

## TEST-03 — The session restarts once, and only when something changed
- **Given** the guided setup hub open
- **When** it is closed without enabling or disabling any feature
- **Then** the session does not restart; after a feature is enabled and the hub is closed, it restarts once

**Automation:** manual, once the first feature ships (the foundation alone has nothing to toggle)
