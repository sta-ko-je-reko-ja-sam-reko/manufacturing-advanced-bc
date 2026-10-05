# Module map and object ID allocation

> **Status: candidate scope, not confirmed scope.**
> The modules below come from where Business Central manufacturing implementations most often go
> wrong, and from what manufacturers usually buy an add-on to get. **There is no customer.** Where a
> decision would need a customer fact, the app picks the least invasive default and makes the
> alternatives swappable (an extensible enum whose values each bind their own interface
> implementation). Read the "Candidate gap" column as a hypothesis to test against real production
> sites, not as a promise.

## Two kinds of module

**Guardrails** catch the expensive mistakes standard BC lets through. Each one sits on a standard flow
(release, refresh, finish, cost adjustment, planning) and either checks it, records it, or explains it.
They are small, they need no new master data, and no ISV covers them well. They come first.

**Capabilities** add what standard BC does not do at all. They are bigger, and some of them compete
with established ISVs. They come after the guardrails.

## Not in scope, because Microsoft now ships it

Checked against the BC 29.0 W1 artifact:

| Need | First-party app in BC 29 | Consequence |
|---|---|---|
| Subcontracting | **Subcontracting** (64 codeunits: subcontracting worksheet, WIP ledger, transfer to subcontractor, prices) | No subcontracting module. Guardrails must tolerate the app being installed (its extra routing and WIP fields) |
| In-process and receiving quality inspection | **Quality Management** (inspection templates, generation rules, dispositions, certificate of analysis) | No quality module. A later feature may *react* to a failed inspection on an output, through that app's own API |
| Production orders themselves | **Manufacturing** is only a licensing shell in BC 29. Production order tables and codeunits are still in the Base Application | No dependency on it. The app depends on the Base Application only |

## Folder convention

Source lives under `app/src/<Feature>/` with object-type subfolders (`tables/ pages/ codeunits/ enums/
interfaces/ tableextensions/ pageextensions/`). A feature folder is created when the feature is scoped,
never up front. File name = object name with the affix removed and spaces and special characters
stripped, then `.<ObjectType>.al`. Every object declares `namespace ManufacturingAdvanced.<Feature>;`.

## Object ID allocation

The app owns block 8 of the owner's PTE range: **85000..88999** for the app and **89000..89999** for the
test app. Blocks of 100 per module, so parallel work never collides.

| Module | Folder | IDs | API group | Standard BC today | Candidate gap to build |
|---|---|---|---|---|---|
| Foundation | `Core` | 85000–85099 | — | — | Setup record, guided setup hub and wizard, feature facade, MCP and configuration-package helpers, number series helper, permission sets. No feature knowledge |
| **Release Pre-flight** | `Preflight` | 85100–85199 | `mfgPreflight` | Release only checks what posting needs later, one error at a time | A swappable set of checks run **before** a production order is released (and on demand), each returning findings with a severity: routing link codes that match no component, backward-flushed lot or serial components with no tracking assigned, missing To-/From-Production and Open Shop Floor bins on locations, work centres and machine centres, components whose flushing method contradicts the location's warehouse handling, BOM or routing versions that are not certified. Block, warn, or log, per check |
| **WIP Control** | `WIPControl` | 85200–85299 | `mfgWip` | WIP is visible only through G/L and the production order statistics; nothing flags an order that should have been finished | Monitor of Released orders whose output is complete but that are not Finished, with WIP value and age. A finish-proposal worksheet that runs pre-finish checks (remaining consumption, open warehouse picks, capacity not posted, uncosted entries) and finishes the orders that pass. A WIP reconciliation per order against the G/L WIP account |
| **Standard Cost Drift** | `CostDrift` | 85300–85399 | `mfgCostDrift` | Standard cost is recalculated only when someone runs the worksheet; variances are posted but not explained | Detects items whose standard cost is stale because their BOM, routing, work-centre cost or component purchase price changed after the last roll-up. Proposes a standard cost worksheet. Variance analysis per order and type (material, capacity, subcontracted, capacity overhead, manufacturing overhead) with drill-down to the entries |
| **Refresh Protection** | `RefreshGuard` | 85400–85499 | `mfgRefreshGuard` | Refresh Production Order with Calculate Lines or Calculate Routings deletes and recreates the lines; manual edits are lost without warning | Snapshot of component and routing lines before a refresh, a diff after it, and a page where the planner re-applies the manual changes they choose. Optionally refuses a refresh that would discard changes |
| **Planning Insight** | `PlanningInsight` | 85500–85599 | `mfgPlanning` | The planning worksheet produces action messages with no history and no explanation of which parameter caused them | Records each planning run's action messages per item, finds the items that churn (repeated Cancel, Reschedule, Change Qty.), and proposes parameter changes (dampener, lot accumulation period, safety lead time, reorder policy) with the evidence |
| **Shop Floor Terminal** | `ShopFloor` | 85600–85699 | `mfgShopFloor` | Output and consumption journals, desktop-shaped pages | Tablet and scanner flows per operation: start and stop, report output and scrap with a reason, record downtime, all posted through the standard journals |
| **Finite Loading** | `FiniteLoading` | 85700–85799 | `mfgLoading` | Capacity is planned infinite; load is visible but not constrained | A light forward finite-loading engine per work centre with a sequencing view. Deliberately not an APS: one constraint (capacity), one direction (forward), swappable strategy |
| **Engineering Change** | `EngineeringChange` | 85800–85899 | `mfgEco` | BOM and routing versions with a status; no change document, no approval, no impact view | Engineering change order with approval, effective dating of the new versions, and where-used impact on open production orders and planning |
| Free | — | 85900–88999 | | | |
| Tests | `test/` | 89000–89999 | | | One test codeunit per feature, plus integration codeunits for posting flows |

## Every feature ships the same way

Each feature, once scoped, carries the whole set below. The foundation already provides the shared parts.

- Its own **setup** table and page with an `Enabled` flag, and a dedicated **application area** that hides
  its operational pages and surfaced controls while it is off. The setup page and the wizard stay visible
  (`ApplicationArea = All`), or a fresh tenant could never switch anything on.
- A value in the **`MFG Feature`** enum bound to its own `MFG IFeatureSetup` implementation, so it appears in
  the guided setup, answers `IsEnabled`, applies the wizard's choices, and registers its MCP configuration.
  No foundation code changes when a feature ships.
- **Polymorphic logic**: no business logic in a table trigger, a table extension or a subscriber body; each
  delegates one line to an interface implementation that tests and dependent apps can replace. No custom
  event publishers.
- **API pages** for every table holding business data, grouped under the feature's own API group, with the
  write triggers guarded by `CheckEnabled`.
- An **MCP configuration** over that API group, with agent instructions in
  `app/docs/FEAT-<mark>/agent-instructions/`.
- **Sample data**: an idempotent demo seeder, reachable from the wizard and from a `[ServiceEnabled]` import API
  in a dedicated `demo<Feature>` API group with its own MCP configuration. On opt-in the seeder also builds the
  feature's **configuration package** (`MFG-<FEATURE>`): its own tables with all fields, the standard tables it
  extends with only their key and the app's fields, and never its setup table.
- A **test codeunit**, test plans, technical documentation and an English getting-started page.
