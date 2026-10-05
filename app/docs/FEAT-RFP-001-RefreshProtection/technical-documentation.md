# FEAT-RFP-001 - Refresh Protection

Segments: **RFP-001** components and operations; **RFP-002** production order lines.

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, refresh runs, component, operation and line snapshots, changes, object kinds
> behind an interface, engine, reactions on the *Refresh Production Order* report, changes pages, actions on the
> firm planned and released production order cards, API pages, MCP configurations, sample data and configuration
> package.
> **Namespaces:** `ManufacturingAdvanced.RefreshGuard`; tests `ManufacturingAdvanced.Test`.

## Business Process

**Refresh Production Order** with *Calculate Lines*, *Calculate Routings* or *Calculate Components* deletes the
order's lines, components or routing lines and calculates them again from the BOM and routing. Anything a planner
changed by hand is gone, without a word. Refresh Protection records what each refresh changed and lets the planner
put it back.

1. An administrator enables **Refresh protection** in the guided setup or on its setup page. *Notify after a
   refresh with changes* starts on.
2. When the report is about to recalculate an order (`OnBeforeCalcProdOrder`, before anything is deleted), the
   app starts a **refresh run** and asks every object kind to take its **snapshot**: every component (line, item,
   variant, quantity per, unit of measure, scrap %, location, bin, flushing method, routing link) and every routing
   line (type, work or machine centre, setup time, run time, routing link).
3. When the report has refreshed the order (`OnAfterRefreshProdOrder`), each object kind compares the order with its
   snapshot and records a **change** per difference:
   - **Components** are matched by order line, item, variant and occurrence (the n-th component of the same item and
     variant on the line). A changed value, a component the refresh removed, and a component it added are all
     restorable.
   - **Operations** are matched by routing reference, routing and operation number. Changed setup time, run time and
     routing link are restorable; a different work or machine centre, a removed operation and an added operation are
     reported only, because re-planning them is the planner's call.
   - **Lines** (RFP-002) are matched by item, variant and occurrence, because the refresh recreates them and may
     renumber them. Changed quantity, location, bin and due date are restorable, through the line's own validation,
     which also updates its components; a different production BOM, routing, either version or unit of measure, a
     removed line and an added line are reported only.
   A run with no changes is removed with its snapshot.
4. With notifications on, the user sees *Refreshing production order … made n change(s)* with **Show changes**.
5. On **Refresh changes**, the user selects lines and chooses **Restore**. A changed value is validated back to the
   value before the refresh; a removed component is re-created from the snapshot through the component's own
   validation; an added component is deleted. Each restored change is marked *Restored* and cannot be restored twice.
6. Agents use the `mfgRefreshGuard` API group: they read runs and changes, and call `restore` on a change.

## Data Model

### New Tables

| Table | ID | Key | Content |
|---|---|---|---|
| MFG Refresh Setup | 85400 | Primary Key | `MFG Enabled`, `Notify on Changes` |
| MFG Refresh Run | 85401 | Run No. (AutoIncrement) | Order status and number, refreshed at and by (`EndUserIdentifiableInformation`), Completed; FlowFields Changes and Open Changes |
| MFG Refresh Comp. Snapshot | 85402 | Run No., Entry No. | Order line, occurrence, component line, and the compared fields **under the same field numbers as `Prod. Order Component`** (11, 12, 13, 19, 20, 21, 28, 30, 33, 45) |
| MFG Refresh Oper. Snapshot | 85403 | Run No., Entry No. | Routing, routing reference, operation, and the compared fields **under the same field numbers as `Prod. Order Routing Line`** (7, 8, 11, 12, 13, 34) |
| MFG Refresh Line Snapshot | 85405 | Run No., Entry No. | Original line number, occurrence, and the compared fields under the same field numbers as `Prod. Order Line` (11, 12, 13, 20, 23, 40, 47, 60, 61, 80), except the version codes, stored in 85750 and 85751 because 99000750 and 99000751 lie outside the app's ID range and mapped back in `MFG Refresh Lines` |
| MFG Refresh Change | 85404 | Run No., Entry No. | Kind, change type, order, order line, subject, field number and caption, old and new value, snapshot entry, current component line, routing key, Restorable, Restored |

Because the snapshot fields share the standard field numbers, comparison and restore are generic: both go through
`RecordRef`, and a restore validates the standard field with the snapshot's value.

### New Fields on Existing Tables

| Object | Field | Type | Notes |
|---|---|---|---|
| Application Area Setup | 85400 MFG Refresh Guard | Boolean | Application area tag `MFGRefreshGuard` |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85400 | MFG Refresh Object Kind | Extensible; implements `MFG IRefreshObject`; default `MFG Refresh No Object` |
| Enum | 85401 | MFG Refresh Change Type | Changed, Removed, Added |
| Interface | — | MFG IRefreshObject | TakeSnapshot, Compare, Restore, DeleteSnapshot |
| Interface | — | MFG IRefreshReactions | OnBeforeRefresh, OnAfterRefresh |
| Codeunit | 85400 | MFG Refresh Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85401 | MFG Refresh App Area Sub. | Application area from the enabled flag |
| Codeunit | 85402 | MFG Refresh Engine | BeginRun, CompleteRun, InsertChange, Restore, RestoreAll, DeleteRun |
| Codeunit | 85403 | MFG Refresh Reactions | Default `MFG IRefreshReactions`: snapshot before, compare and notify after |
| Codeunit | 85404 | MFG Refresh Locator | Single-instance resolver of the reactions, with `Implement()` |
| Codeunit | 85405 | MFG Refresh Events | Subscriber proxy on the report's two events |
| Codeunit | 85406 | MFG Refresh Session | Single-instance map from order to the run started for it |
| Codeunit | 85407 | MFG Refresh Notification | Notification with the *Show changes* action |
| Codeunit | 85408 | MFG Demo Refresh | Sample data and configuration package |
| Codeunit | 85409 | MFG Refresh No Object | Default object kind: records nothing |
| Codeunit | 85410 | MFG Refresh Components | Object kind: components |
| Codeunit | 85411 | MFG Refresh Operations | Object kind: routing lines |
| Codeunit | 85412 | MFG Refresh Lines | Object kind: production order lines (RFP-002) |
| Page | 85400 | MFG Refresh Setup | Setup card (`ApplicationArea = All`) |
| Page | 85401 | MFG Refresh Runs | *Production order refreshes* (history) |
| Page | 85402 | MFG Refresh Changes | Changes with **Restore** |
| Page | 85403 | MFG API Refresh Run | API `refreshRuns`, read-only |
| Page | 85404 | MFG API Refresh Change | API `refreshChanges`, read-only, bound action `restore` (guarded by `CheckEnabled`) |
| Page | 85405 | MFG API Demo Refresh | API group `demoRefreshGuard`, bound action `importDemoData` |
| Page extension | 85400 | MFG Refresh Firm Planned Order | *Refresh changes* on the firm planned order card |
| Page extension | 85401 | MFG Refresh Released Order | *Refresh changes* on the released order card |

## Files

```
app/src/RefreshGuard/
├── codeunits/      DemoRefresh, RefreshAppAreaSub, RefreshComponents, RefreshEngine, RefreshEvents,
│                   RefreshFeatureSetup, RefreshLines, RefreshLocator, RefreshNoObject, RefreshNotification,
│                   RefreshOperations, RefreshReactions, RefreshSession
├── enums/          RefreshChangeType, RefreshObjectKind
├── interfaces/     IRefreshObject, IRefreshReactions
├── pageextensions/ RefreshFirmPlannedOrder, RefreshReleasedOrder
├── pages/          APIDemoRefresh, APIRefreshChange, APIRefreshRun, RefreshChanges, RefreshRuns, RefreshSetup
├── tableextensions/RefreshApplArea
└── tables/         RefreshChange, RefreshCompSnapshot, RefreshOperSnapshot, RefreshRun, RefreshSetup
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Before refresh | Report `Refresh Production Order`.`OnBeforeCalcProdOrder` | Proxy → locator → reactions → `BeginRun`. Fires before any line is deleted |
| After refresh | Report `Refresh Production Order`.`OnAfterRefreshProdOrder` | Proxy → locator → reactions → `CompleteRun` and the notification |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Refresh Guard` from the enabled flag |

Both subscribers set `SkipOnMissingLicense` and `SkipOnMissingPermission`. Every reaction's first line is the
feature's `Enabled` guard.

## Extending the feature

- **Protect more of the order**, for example the production order lines themselves: an `enumextension` on
  `MFG Refresh Object Kind` bound to an `MFG IRefreshObject` implementation. The engine snapshots, compares, restores
  and cleans it up with no change to this app.
- **Replace what happens around a refresh**, for example to refuse a refresh that would discard changes: implement
  `MFG IRefreshReactions` and call `Implement()` on `MFG Refresh Locator`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Refresh Protection | `refreshRuns` (read), `refreshChanges` (read, `restore`) | [agent-instructions/MFG-Refresh.md](agent-instructions/MFG-Refresh.md) |
| Manufacturing Advanced - Demo Refresh Protection | `demoRefreshGuardSet` (`importDemoData`) | [agent-instructions/MFG-Demo-Refresh.md](agent-instructions/MFG-Demo-Refresh.md) |

## Data Import

Sample data only, through `MFG Demo Refresh`.Import:

- Firm planned order **MFG-RFP-001** for the first certified manufactured item, quantity 1, calculated with
  `Create Prod. Order Lines`. The quantity per of its first component is raised by one, as a planner would, then the
  order is recalculated inside a run, so the run records the discarded change and it can be restored. Skipped when the
  order exists or the company has no such item. It does not need the feature to be enabled.
- Configuration package **MFG-REFRESH** with the run, change and the three snapshot tables, all fields. The setup table is
  never in it.

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| Base Application | Microsoft | Production orders, components, routing lines, the *Refresh Production Order* report |
| FEAT-CORE-001 | This app | Feature enum, facade, guided setup, MCP and configuration-package helpers |

## Known Limitations

- Only refreshes through the *Refresh Production Order* report are recorded. Code that calls `Create Prod. Order
  Lines` or `Calculate Prod. Order` directly is not.
- A removed or added production order line is reported only. Re-creating a line needs its components and routing
  calculated again, which is a refresh of its own.
- The refresh is not refused; the app only records and restores. Refusing is a reactions implementation away.
