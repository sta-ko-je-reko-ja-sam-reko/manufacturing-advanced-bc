# manufacturing-advanced-bc

AL app for Dynamics 365 Business Central Cloud that adds **guardrails** and **capabilities** to the
manufacturing module.

Standard Business Central manufacturing is capable but unforgiving. The most expensive mistakes are not
missing features; they are things the standard flows let through without a word:

- **Work in progress that never settles.** Costs are final only when a production order is finished.
  Orders left Released keep their WIP on the balance sheet, and margins stay wrong until somebody notices.
- **Flushing, item tracking and warehouse handling that do not agree.** A backward-flushed lot-tracked
  component with no lot assigned fails at posting; a missing routing link code flushes a component at the
  wrong operation; a missing production bin breaks the pick.
- **Refresh Production Order discards manual changes** to component and routing lines without a warning.
- **Stale standard costs and noisy planning.** Variances pile up when nobody rolls up standard cost, and
  planners stop trusting a worksheet full of Cancel and Reschedule messages.

This app catches those problems before they cost money, then adds what manufacturers usually buy an
add-on for: a shop floor terminal, engineering change orders and light finite loading.

## Status

**Foundation delivered; features in progress.** The foundation is the setup record, the guided setup
with its per-feature wizard, the feature facade, the MCP, configuration-package and number series helpers,
and the permission sets. It is covered by 12 tests. Both projects build with zero errors and zero warnings
against Business Central 29 W1.

| # | Feature | Kind | Status |
|---|---|---|---|
| 0 | Foundation | — | Delivered |
| 1 | Release Pre-flight: checks before a production order is released | Guardrail | Next |
| 2 | WIP Control: unfinished orders, finish proposals, WIP reconciliation | Guardrail | Planned |
| 3 | Refresh Protection: snapshot, diff and re-apply around a refresh | Guardrail | Planned |
| 4 | Standard Cost Drift: stale standards and explained variances | Guardrail | Planned |
| 5 | Planning Insight: action-message history and parameter advice | Guardrail | Planned |
| 6 | Shop Floor Terminal | Capability | Planned |
| 7 | Engineering Change | Capability | Planned |
| 8 | Finite Loading (light, single constraint) | Capability | Planned |

The scope is a hypothesis: **there is no customer**. [app/docs/modules.md](app/docs/modules.md) describes
each module against what standard BC does today, and lists what is deliberately out of scope because
Microsoft now ships it (Subcontracting, Quality Management). [app/docs/roadmap.md](app/docs/roadmap.md)
gives the build order, and [app/docs/architecture.md](app/docs/architecture.md) explains how it is put
together.

## How it is built

- **Every feature is switched on separately**, with its own setup page, its own application area, and a
  step in the guided setup. A feature that is off changes nothing.
- **Polymorphic logic.** No business logic in table triggers or event-subscriber bodies: each delegates
  one line to an interface implementation that a test or a dependent app can replace. Strategies a customer
  would choose are extensible enums implementing an interface. The app publishes no events of its own.
- **APIs and MCP.** Every table holding business data has an API page in its feature's own API group, and
  each feature registers an MCP configuration over that group, so an agent gets exactly one feature's tools.
- **Sample data and configuration packages.** Each feature ships an idempotent sample data seeder, reachable
  from the wizard and from an API. Loading sample data also builds the feature's RapidStart configuration
  package.
- **Tests** ship with every feature, in a separate test app.

## Target

- Business Central **29.0** W1 (runtime 18.0), per-tenant extension, `target: Cloud`
- No dependency beyond the Base and System Applications
- Publisher `matr`, affix `MFG`, object IDs 85000..88999, tests 89000..89999

## Repository layout

```
manufacturing-advanced-bc.code-workspace   Open THIS in VS Code, not the repo folder
app/       The extension: src/Core, src/PermissionSet, src/<Feature>, docs/, img/, Translations/
test/      The test app
tools/     build.ps1 compiles app and test with all four code analyzers
           test.ps1 publishes both to the dev container and runs the tests
```

## Building

The project follows the owner's private BC conventions, wired in locally as the gitignored junctions
`.bc-conventions` and `.greenfield`. **A fresh clone does not build without them**: the project rulesets
include `../.bc-conventions/ruleset.json`. That is a deliberate trade, keeping the methodology private while
the product is public.

```powershell
.\tools\build.ps1                          # app + test, CodeCop, UICop, AppSourceCop, PerTenantExtensionCop
.\tools\test.ps1 -ContainerName bc29loc    # elevated, BcContainerHelper; writes .output\TestResults.xml
```

## License

Copyright (c) 2026 Marko Trnavac. All rights reserved — see [LICENSE](LICENSE). The source is public to
read; it is not open source.
