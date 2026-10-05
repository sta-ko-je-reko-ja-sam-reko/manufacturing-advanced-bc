# Architecture

How Manufacturing Advanced is put together, and the rules every feature follows. The per-feature
detail lives in each `FEAT-*` folder's technical documentation.

## One foundation, many switchable features

```
Core (always on)                         Feature (one per module, off until enabled)
├── MFG Setup + MFG ISetup               ├── <Feature> Setup table + page (Enabled)
├── MFG Feature enum ───────────────────►├── enum value bound to its MFG IFeatureSetup
│     implements MFG IFeatureSetup       ├── application area (Application Area Setup field)
├── MFG Feature Mgt. (facade)            ├── tables, each with an interface + logic codeunit
├── Guided setup hub + wizard            ├── subscriber proxies on standard flows
├── MFG MCP Setup                        ├── API pages (one API group per feature)
├── MFG Config. Package Mgt.             ├── demo seeder + demo import API (own API group)
└── MFG No. Series Mgt.                  └── test codeunit
```

The foundation knows no feature by name. It iterates the `MFG Feature` enum and asks each value, through
its `MFG IFeatureSetup` implementation, to register a guided setup step, say whether it is enabled, apply
the wizard's choices and register its MCP configuration. A feature ships by adding an enum value and its
implementation; a dependent app adds a feature the same way, with an `enumextension`.

## Polymorphic logic, no publishers

- **Tables** hold a resolver: a cached interface variable, a local `Logic()` that defaults to the built-in
  logic codeunit, and a public `Define()` that replaces it. Triggers and field validations are one-line
  delegations. `MFG Setup` is the first example.
- **Subscribers** to Microsoft's events live in proxy codeunits whose bodies forward one line to an
  interface resolved per feature. The first line of the resolved logic is the feature's `Enabled` guard,
  so a disabled feature never reacts.
- **Strategies** that a customer would choose (which pre-flight checks run, how a finish proposal decides,
  how a finite loader sequences) are extensible enums implementing an interface, selected in the feature's
  setup.
- **No custom `[IntegrationEvent]` or `[BusinessEvent]` publishers.** A dependent app replaces an
  implementation; it does not subscribe to ours.

That is also what makes the logic testable without a database: a test calls the logic codeunit with an
in-memory or temporary record, or injects a fake through `Define()`.

## Data reaches the outside through APIs

- Every table holding business data has an API page under publisher `matr`, version `v1.0`, and the
  feature's own API group (`mfgPreflight`, `mfgWip`, …). Write triggers call `CheckEnabled`, because
  application areas hide the UI but not the API.
- Each feature registers an **MCP configuration** over its API group on install and upgrade, so an agent is
  given exactly one feature's tools. Agent instructions for each configuration are kept in the feature's
  docs folder, in sync with its tools.
- Demo importers are `[ServiceEnabled]` actions in a separate `demo<Feature>` API group with their own MCP
  configuration, so a seeding agent never gets the functional write tools.

## Configuration packages

A feature's sample data seeder builds that feature's RapidStart **configuration package** (`MFG-<FEATURE>`)
when, and only when, the user chooses to load sample data. The package holds the feature's own tables with
all fields and the standard tables it extends with only their primary key and the app's fields, and never
the feature's setup table, which belongs to the guided setup. `MFG Config. Package Mgt.` does the work, on
top of the standard `Config. Package Management`.

## Standard objects this app builds on

Production orders, BOMs, routings, work and machine centres, the output and consumption journals, the
planning worksheet and cost adjustment are all in the **Base Application** in BC 29. Microsoft's separate
*Manufacturing* app is a licensing shell with no objects, so the app does not depend on it. Microsoft's
*Subcontracting* and *Quality Management* apps are out of scope (see [modules.md](modules.md)), and every
guardrail must keep working when they are installed.
