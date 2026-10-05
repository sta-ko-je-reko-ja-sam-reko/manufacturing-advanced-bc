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

**Every module on the roadmap has a first working segment.** Each one is switched on separately, has its own setup,
application area, API group, MCP configuration with agent instructions, sample data with a configuration package, and
a test codeunit. The test app holds 124 tests. Both projects build with zero errors and zero warnings against Business
Central 29 W1.

| # | Feature | Kind | What it does |
|---|---|---|---|
| 0 | Foundation | — | Guided setup, feature facade, MCP, configuration-package and number series helpers |
| 1 | Release Pre-flight | Guardrail | Checks a production order before release: dead routing links, flushing without tracking, missing bins, uncertified designs, flushing against warehouse handling |
| 2 | WIP Control | Guardrail | Finds released orders with complete output, values their WIP, checks and finishes them, and reconciles each order's WIP with the G/L |
| 3 | Refresh Protection | Guardrail | Records what Refresh Production Order changed, manual edits included, and restores them |
| 4 | Standard Cost Drift | Guardrail | Lists stale standard costs against roll-up and purchase price, feeds the standard cost worksheet, shows order variances |
| 5 | Planning Insight | Guardrail | Keeps the history of action messages and advises which planning parameter to adjust |
| 6 | Shop Floor Terminal | Capability | Start and stop operations, report output, scrap and downtime, posted through the standard journal |
| 7 | Engineering Change | Capability | Change orders for BOM and routing versions with approval, effective date and impact |
| 8 | Finite Loading | Capability | Capacity-aware load plan per work center with swappable sequencing |

The scope is a hypothesis: **there is no customer**. [app/docs/modules.md](app/docs/modules.md) describes each module
against what standard BC does today, and lists what is deliberately out of scope because Microsoft ships it
(Subcontracting, Quality Management). [app/docs/roadmap.md](app/docs/roadmap.md) records what each first segment covers,
and [app/docs/architecture.md](app/docs/architecture.md) explains how it is put together.

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
