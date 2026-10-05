# FEAT-PRE-001 - Release Pre-flight

Segments: **PRE-001** the first four checks; **PRE-002** flushing method against warehouse handling.

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, check configuration, findings, five checks behind an interface, engine,
> release reaction on `Prod. Order Status Management`, actions on the firm planned and released production
> order cards, API pages, MCP configurations, sample data and configuration package.
> **Namespaces:** `ManufacturingAdvanced.Preflight`; tests `ManufacturingAdvanced.Test`.

## Business Process

1. An administrator enables **Release pre-flight** in the guided setup or on its setup page. The setup
   starts with *Check on release*, *Block release on errors* and *Ask before releasing with warnings* all on,
   and one configuration row per check with that check's default severity.
2. When a production order is about to change status to **Released**, by any route that goes through
   `Prod. Order Status Management`, the app runs every check whose severity is not *Off* against the order:
   - **Routing link without operation** (default *Warning*): a component's routing link code matches no
     operation of its order line (same routing number and routing reference). Such a component is never
     consumed at an operation, and backward flushing never picks it up.
   - **Automatic flushing without item tracking** (default *Error*): a component flushed *Forward*,
     *Backward*, *Pick + Forward* or *Pick + Backward* whose item tracking code is lot or serial specific (or
     tracks manufacturing outbound) has lot or serial numbers assigned for less than its remaining quantity.
     The flushing would fail when it posts.
   - **Missing bin** (default *Error*): an output line or component at a location with *Bin Mandatory* has
     no bin code, so output or consumption cannot post.
   - **BOM or routing not certified** (default *Warning*): the production BOM or routing a line was calculated
     from, or the version of either, is no longer certified or no longer exists.
   - **Flushing method against warehouse handling** (default *Warning*, PRE-002), for a component with remaining
     quantity, following the rules of `Whse.-Production Release` and `Prod. Order Warehouse Mgt.`:
     - a *Pick + Manual*, *Pick + Forward* or *Pick + Backward* component at a location whose *Prod. Consump.
       Whse. Handling* is *No Warehouse Handling* and that does not *Require Pick*: no pick is ever created;
     - a *Pick + Forward* component without a routing link code: the standard release creates no pick request
       for it, and it is flushed at release;
     - a *Forward* or *Backward* component at a location whose handling is *Warehouse Pick (mandatory)*: no pick
       is created, so it is consumed from the production bin only if something else put it there.
3. The findings replace the order's previous findings and are stored with the time and the user.
4. If any finding has severity *Error* and blocking is on, the status change fails with an error that names the
   order, the number of errors and the first five findings. Because the error rolls back the transaction, the
   findings it stored are rolled back with it; the message tells the user to choose **Run pre-flight**, which
   stores them for good.
5. Otherwise, if there are warnings (or errors while blocking is off) and confirmation is on, the user is
   asked whether to release anyway. Declining stops the release silently.
6. At any time, **Run pre-flight** on the firm planned or released production order card runs the same checks,
   stores the findings and opens them; **Pre-flight findings** shows the last stored run.
7. Agents use the `mfgPreflight` API group: they read findings, change a check's severity, and call the
   `runPreflight` bound action on a production order.

## Data Model

### New Tables

`MFG Preflight Setup` (85100), single record:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Primary Key | Code[10] | |
| 10 | MFG Enabled | Boolean | The feature switch; drives the `MFGPreflight` application area |
| 20 | Check on Release | Boolean | Run the checks automatically on release. Default on |
| 21 | Block on Errors | Boolean | Refuse a release with errors. Default on |
| 22 | Confirm Warnings | Boolean | Ask before releasing with warnings. Default on |

`MFG Preflight Check` (85101), one row per check:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Check | Enum `MFG Preflight Check Type` | Primary key |
| 10 | Severity | Enum `MFG Preflight Severity` | Off, Warning, Error |
| 20 | Description | Text[250] | Taken from the check's implementation when the row is created |

`MFG Preflight Finding` (85102):

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Entry No. | Integer | AutoIncrement, primary key |
| 10 | Prod. Order Status | Enum `Production Order Status` | Status at check time |
| 11 | Prod. Order No. | Code[20] | |
| 12 | Prod. Order Line No. | Integer | Zero for the whole order |
| 13 | Component Line No. | Integer | Zero for the output |
| 20 | Check | Enum `MFG Preflight Check Type` | |
| 21 | Severity | Enum `MFG Preflight Severity` | |
| 22 | Message | Text[250] | What is wrong and what to do |
| 30 | Item No. | Code[20] | |
| 31 | Location Code | Code[10] | |
| 40 | Checked At | DateTime | |
| 41 | Checked By | Code[50] | `EndUserIdentifiableInformation` |

Secondary key `Order`: Prod. Order Status, Prod. Order No., Severity.

### New Fields on Existing Tables

| Object | Field | Type | Notes |
|---|---|---|---|
| Application Area Setup | 85100 MFG Preflight | Boolean | Application area tag `MFGPreflight` |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Table | 85100 | MFG Preflight Setup | Feature setup |
| Table | 85101 | MFG Preflight Check | Severity per check |
| Table | 85102 | MFG Preflight Finding | Stored findings |
| Table extension | 85100 | MFG Preflight Appl. Area | Application area field |
| Enum | 85100 | MFG Preflight Check Type | Extensible; implements `MFG IPreflightCheck`; default `MFG Preflight No Check` |
| Enum | 85101 | MFG Preflight Severity | Off, Warning, Error |
| Interface | — | MFG IPreflightCheck | Run(order, collector), DefaultSeverity, Description |
| Interface | — | MFG IPreflightReactions | OnBeforeChangeStatus(order, new status) |
| Codeunit | 85100 | MFG Preflight Feature Setup | `MFG IFeatureSetup`: guided setup step, enabled flag, wizard choices, MCP configurations |
| Codeunit | 85101 | MFG Preflight App Area Sub. | Sets the application area from the enabled flag |
| Codeunit | 85102 | MFG Preflight Engine | RunChecks, StoreFindings, RunAndStore, RunInteractive, CountFindings, EnsureChecks |
| Codeunit | 85103 | MFG Preflight Reactions | Default `MFG IPreflightReactions`: run on release, block or confirm |
| Codeunit | 85104 | MFG Preflight Locator | Single-instance resolver of the reactions, with `Implement()` |
| Codeunit | 85105 | MFG Preflight Events | Subscriber proxy: one-line delegation to the locator |
| Codeunit | 85106 | MFG Demo Preflight | Sample data and configuration package |
| Codeunit | 85107 | MFG Preflight No Check | Default check: finds nothing, severity Off |
| Codeunit | 85108 | MFG Preflight Collector | Collects findings; carries the order, check and severity |
| Codeunit | 85110 | MFG Check Routing Link | Check 1 |
| Codeunit | 85111 | MFG Check Flushing Tracking | Check 2 |
| Codeunit | 85112 | MFG Check Missing Bin | Check 3 |
| Codeunit | 85113 | MFG Check Uncertified Design | Check 4 |
| Codeunit | 85114 | MFG Check Flushing Whse. | Check 5 (PRE-002) |
| Page | 85100 | MFG Preflight Setup | Setup card (`ApplicationArea = All`), with the checks part |
| Page | 85101 | MFG Preflight Checks | ListPart: severity per check |
| Page | 85102 | MFG Preflight Findings | List of findings |
| Page | 85103 | MFG API Preflight Finding | API `preflightFindings`, read-only |
| Page | 85104 | MFG API Preflight Check | API `preflightChecks`, severity writable, guarded by `CheckEnabled` |
| Page | 85105 | MFG API Preflight Order | API `preflightOrders` over planned, firm planned and released orders, bound action `runPreflight` |
| Page | 85106 | MFG API Demo Preflight | API group `demoPreflight`, bound action `importDemoData` |
| Page extension | 85100 | MFG Firm Planned Prod. Order | Run pre-flight, Pre-flight findings |
| Page extension | 85101 | MFG Released Prod. Order | Run pre-flight, Pre-flight findings |

Operational UI carries `ApplicationArea = MFGPreflight`; the setup page is `All`. The actions added to the
standard order cards also carry `AccessByPermission = tabledata "MFG Preflight Setup" = R`.

## Files

```
app/src/Preflight/
├── codeunits/      CheckFlushingTracking, CheckFlushingWhse, CheckMissingBin, CheckRoutingLink, CheckUncertifiedDesign,
│                   DemoPreflight, PreflightAppAreaSub, PreflightCollector, PreflightEngine, PreflightEvents,
│                   PreflightFeatureSetup, PreflightLocator, PreflightNoCheck, PreflightReactions
├── enums/          PreflightCheckType, PreflightSeverity
├── interfaces/     IPreflightCheck, IPreflightReactions
├── pageextensions/ FirmPlannedProdOrder, ReleasedProdOrder
├── pages/          APIDemoPreflight, APIPreflightCheck, APIPreflightFinding, APIPreflightOrder,
│                   PreflightChecks, PreflightFindings, PreflightSetup
├── tableextensions/PreflightApplArea
└── tables/         PreflightCheck, PreflightFinding, PreflightSetup
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Release | `Prod. Order Status Management`.`OnBeforeChangeStatusOnProdOrder` | Proxy → locator → reactions. `SkipOnMissingLicense` and `SkipOnMissingPermission` are on |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Preflight` from the enabled flag |
| Sample order | `Create Prod. Order Lines`.Copy | Calculates lines, components and routing of the sample order |

## Extending the feature

- **Add a check**: an `enumextension` on `MFG Preflight Check Type` with a value bound to a codeunit
  implementing `MFG IPreflightCheck`. The engine runs it, the setup page lists it, and its findings are
  stored and returned through the API with no change to this app.
- **Replace the release behaviour**: call `Implement()` on `MFG Preflight Locator` with another
  `MFG IPreflightReactions`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Release Pre-flight | `preflightFindings` (read), `preflightChecks` (read, modify), `preflightOrders` (read, `runPreflight`) | [agent-instructions/MFG-Preflight.md](agent-instructions/MFG-Preflight.md) |
| Manufacturing Advanced - Demo Release Pre-flight | `demoPreflightSet` (`importDemoData`) | [agent-instructions/MFG-Demo-Preflight.md](agent-instructions/MFG-Demo-Preflight.md) |

## Data Import

Sample data only, through `MFG Demo Preflight`.Import, from the wizard or the `importDemoData` action:

- The five check rows (idempotent through `EnsureChecks`).
- Firm planned order **MFG-PRE-001** for the first non-blocked item with replenishment *Prod. Order* and a
  certified production BOM, quantity 1, calculated with `Create Prod. Order Lines`. Its first component gets
  routing link **MFG-DEMO** (created if missing), which no operation has, and the checks are run so findings
  exist. Skipped when the order exists or the company has no such item.
- Configuration package **MFG-PREFLIGHT** with `MFG Preflight Check` and `MFG Preflight Finding`, all fields.
  The setup table is never in it. Created only on this path, once.

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| Base Application | Microsoft | Production orders, components, routing lines, BOMs, routings, locations, item tracking |
| FEAT-CORE-001 | This app | Feature enum, facade, guided setup, MCP and configuration-package helpers |

## Known Limitations

- An error that blocks a release rolls back the findings it stored; the error lists the first five, and
  **Run pre-flight** stores all of them.
- The flushing tracking check counts lot and serial numbers assigned on the component; it does not check that
  the lots are available in the bin the flushing will take them from.
- The flushing against warehouse handling check reads the location of the component. A blank location is
  not checked for the pick methods, because its handling comes from the warehouse setup.
