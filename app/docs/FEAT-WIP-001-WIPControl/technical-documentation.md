# FEAT-WIP-001 - WIP Control

Segments: **WIP-001** proposals, checks and finishing; **WIP-002** reconciliation of each order's WIP with the
G/L WIP accounts; **WIP-003** a scheduled daily run and reconciliation history.

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, finish checks, finish proposals, WIP valuation behind an interface,
> engine, finish proposal worksheet, action on the released production order list, API pages, MCP
> configurations, sample data and configuration package.
> **Namespaces:** `ManufacturingAdvanced.WIPControl`; tests `ManufacturingAdvanced.Test`.

## Business Process

Business Central settles a production order's cost only when the order is **finished** and costs are
adjusted. An order left *Released* after its last output keeps its work in progress on the balance sheet,
its variances are never posted, and nothing in the standard product points at it. WIP Control finds those
orders and finishes them safely.

1. An administrator enables **WIP control** in the guided setup or on its setup page, and may set
   *Min. days since last output* (default 0) and *Update unit cost on finish* (default off).
2. **Suggest** on the *Finish proposals* worksheet rebuilds the proposals. Every released production order
   whose lines exist and have no remaining quantity, and whose last output is at least the minimum number of
   days old, gets a proposal with:
   - quantity and finished quantity from its lines;
   - **consumption cost, capacity cost, output cost and estimated WIP** from the valuation (default: the
     order's value entries, consumption + capacity − output, actual and expected);
   - the date of the last output and the days since, counted to the work date;
   - the result of the checks before finishing.
3. The checks, each with a severity of *Block*, *Inform* or *Off*:
   - **Consumption still missing** (default *Block*): a component still has remaining quantity.
   - **Open warehouse picks** (default *Block*): a warehouse or inventory pick line for the order's
     components is still open.
   - **Operations not finished** (default *Inform*): a routing line's routing status is not *Finished*.
   A *Block* finding sets the proposal to **Blocked** and clears *Selected*; *Inform* findings only add notes.
4. The user selects proposals (or **Select all ready**) and chooses **Finish selected**. Each selected, ready
   order is finished through the standard status change (`Prod. Order Status Management`.ChangeProdOrderStatus,
   status *Finished*, work date, *Update unit cost* from the setup), one at a time with a commit before each, so
   that a failure does not undo the orders before it. A finished order's proposal becomes **Finished**; a failure
   becomes **Failed** with the error in its notes.
5. Agents use the `mfgWip` API group: they read proposals, change a check's severity, and call
   `evaluateFinish` or `finishOrder` on a released production order.
6. **WIP reconciliation (WIP-002).** **Reconcile** on the *WIP reconciliation* page (also opened from *Finish
   proposals*) compares, for every released order and every order finished within *Reconciliation days* of the
   work date (default 30):
   - **WIP in value entries**: the valuation used for the proposals (consumption + capacity − output);
   - **WIP in G/L**: the G/L entries on the WIP accounts of the inventory posting setup that were posted from the
     order's value entries, followed through `G/L - Item Ledger Relation`;
   - **Cost not posted to G/L**: the order's actual cost minus *Cost Posted to G/L* on its value entries.

   A difference within *Reconciliation tolerance* (default 1) is **Matched**; a larger one with more than the
   tolerance not yet posted to G/L is **Not posted to G/L yet** (run *Post Inventory Cost to G/L*); any other is
   **Investigate**. Agents read `wipReconciliations` and call `reconcileWip` on one order.
7. **Daily run and history (WIP-003).** **Schedule daily run** on the setup creates a recurring job queue entry
   (daily at 02:00, `Job Queue Entry`.ScheduleRecurrentJobQueueEntryWithRunDateFormula) that runs
   `MFG WIP Scheduled Run`: **Suggest**, then **Reconcile**, and nothing while the feature is off. **Remove daily run**
   deletes it. Every reconciled order also gets a **history entry** dated on the work date, so the trend of an order's
   difference can be followed; entries older than *Keep reconciliation history (days)* (default 90, 0 keeps all) are
   removed when the reconciliation runs. Agents read `wipReconciliationEntries`.

## Data Model

### New Tables

`MFG WIP Setup` (85200), single record:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Primary Key | Code[10] | |
| 10 | MFG Enabled | Boolean | The feature switch; drives the `MFGWIPControl` application area |
| 20 | Min. Days Since Output | Integer | Days since the last output before an order is proposed. Default 0 |
| 30 | Update Unit Cost | Boolean | Passed to the standard status change. Default off |
| 40 | Reconciliation Tolerance | Decimal | Largest difference still matched. Default 1 |
| 41 | Reconciliation Days | Integer | Finished orders reconciled this many days back from the work date. Default 30 |
| 50 | Keep History (Days) | Integer | Reconciliation history kept, in days. Default 90; 0 keeps everything (WIP-003) |

`MFG Finish Check` (85201): Check (enum, primary key), Severity (Off, Inform, Block), Description.

`MFG Finish Proposal` (85202):

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Prod. Order No. | Code[20] | Primary key; a released production order |
| 10–13 | Description, Source No., Quantity, Finished Quantity | | From the order and its lines |
| 20 | Last Output Date | Date | Latest posting date of the order's output value entries |
| 21 | Days Since Output | Integer | Work date − last output date |
| 30–33 | Consumption Cost, Capacity Cost, Output Cost, Est. WIP Amount | Decimal | From the valuation |
| 40 | Status | Enum `MFG Finish Proposal Status` | Ready, Blocked, Finished, Failed |
| 41 | Notes | Text[250] | Check findings joined with ` \| `, or the finish error |
| 42 | Selected | Boolean | Finished by *Finish selected* |
| 50 | Suggested At | DateTime | |

`MFG WIP Reconciliation` (85203), rebuilt by **Reconcile**:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Prod. Order Status | Enum `Production Order Status` | Primary key; Released or Finished |
| 2 | Prod. Order No. | Code[20] | Primary key |
| 10–11 | Source No., Description | | From the order |
| 20 | Value WIP | Decimal | From the valuation |
| 21 | G/L WIP | Decimal | From the G/L source |
| 22 | Difference | Decimal | Value WIP − G/L WIP |
| 23 | Unposted Cost | Decimal | Actual cost not posted to G/L |
| 30 | Status | Enum `MFG WIP Recon. Status` | Matched, Not posted to G/L yet, Investigate |
| 40 | Reconciled At | DateTime | |

`MFG WIP Recon. Entry` (85204, WIP-003): one row per order per reconciliation — Entry No. (AutoIncrement),
Reconciled On (work date), order status and number, source no., value WIP, G/L WIP, difference, unposted cost,
status, reconciled at. Keys by order and date.

### New Fields on Existing Tables

| Object | Field | Type | Notes |
|---|---|---|---|
| Application Area Setup | 85200 MFG WIP Control | Boolean | Application area tag `MFGWIPControl` |

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Table | 85200 | MFG WIP Setup | Feature setup |
| Table | 85201 | MFG Finish Check | Severity per check |
| Table | 85202 | MFG Finish Proposal | Proposals |
| Table extension | 85200 | MFG WIP Appl. Area | Application area field |
| Enum | 85200 | MFG Finish Check Type | Extensible; implements `MFG IFinishCheck`; default `MFG Finish No Check` |
| Enum | 85201 | MFG Finish Check Severity | Off, Inform, Block |
| Enum | 85202 | MFG Finish Proposal Status | Ready, Blocked, Finished, Failed |
| Table | 85203 | MFG WIP Reconciliation | Reconciliation per order (WIP-002) |
| Enum | 85203 | MFG WIP Recon. Status | Matched, Not posted to G/L yet, Investigate |
| Interface | — | MFG IGLWipSource | GLWipAmount(order), UnpostedCost(order) |
| Interface | — | MFG IFinishCheck | Evaluate(order, var reason), DefaultSeverity, Description |
| Interface | — | MFG IWipValuation | Calculate(order, var proposal) |
| Codeunit | 85200 | MFG WIP Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85201 | MFG WIP App Area Sub. | Application area from the enabled flag |
| Codeunit | 85202 | MFG WIP Engine | Suggest, EvaluateOrder, FinishSelected, FinishOrder, IsOutputComplete, EnsureChecks, Reconcile, ReconcileOrder |
| Codeunit | 85203 | MFG WIP Finish Order | Runs the standard status change for one order; isolated so `Codeunit.Run` can catch its error |
| Codeunit | 85204 | MFG WIP Value Entries | Default `MFG IWipValuation` |
| Codeunit | 85205 | MFG Demo WIP | Sample data and configuration package |
| Codeunit | 85206 | MFG Finish No Check | Default check: finds nothing, severity Off |
| Codeunit | 85207 | MFG WIP Locator | Single-instance resolver of the valuation (`Implement()`, `ResetValuation()`) and of the G/L source (`GLSource()`, `ImplementGLSource()`, `ResetGLSource()`) |
| Codeunit | 85210 | MFG Check Missing Consumption | Check 1 |
| Codeunit | 85211 | MFG Check Open Whse. Activity | Check 2 |
| Codeunit | 85212 | MFG Check Unfinished Ops. | Check 3 |
| Codeunit | 85213 | MFG WIP GL Source | Default `MFG IGLWipSource` |
| Codeunit | 85214 | MFG WIP Scheduled Run | Job queue codeunit: `Engine.RunScheduled` (WIP-003) |
| Codeunit | 85215 | MFG WIP Job Scheduler | Schedule, IsScheduled, Unschedule of the daily run |
| Table | 85204 | MFG WIP Recon. Entry | Reconciliation history |
| Page | 85200 | MFG WIP Setup | Setup card (`ApplicationArea = All`) with the checks part |
| Page | 85201 | MFG Finish Checks | ListPart |
| Page | 85202 | MFG Finish Proposals | Worksheet: Suggest, Select all ready, Finish selected, WIP reconciliation, Open production order |
| Page | 85203 | MFG API Finish Proposal | API `finishProposals`, read-only |
| Page | 85204 | MFG API Finish Check | API `finishChecks`, severity writable, guarded by `CheckEnabled` |
| Page | 85205 | MFG API WIP Order | API `wipOrders` over released orders; bound actions `evaluateFinish`, `finishOrder`, `reconcileWip` |
| Page | 85206 | MFG API Demo WIP | API group `demoWip`, bound action `importDemoData` |
| Page | 85207 | MFG WIP Reconciliation | List: Reconcile, Open production order |
| Page | 85208 | MFG API WIP Reconciliation | API `wipReconciliations`, read-only |
| Page | 85209 | MFG WIP Recon. Entries | Reconciliation history |
| Page | 85210 | MFG API WIP Recon. Entry | API `wipReconciliationEntries`, read-only |
| Page extension | 85200 | MFG Released Prod. Orders | *Finish proposals* on the released production order list |

## Files

```
app/src/WIPControl/
├── codeunits/      CheckMissingConsumption, CheckOpenWhseActivity, CheckUnfinishedOps, DemoWip,
│                   FinishNoCheck, WipAppAreaSub, WipEngine, WipFeatureSetup, WipFinishOrder,
│                   WipGLSource, WipJobScheduler, WipLocator, WipScheduledRun, WipValueEntries
├── enums/          FinishCheckSeverity, FinishCheckType, FinishProposalStatus, WipReconStatus
├── interfaces/     IFinishCheck, IGLWipSource, IWipValuation
├── pageextensions/ ReleasedProdOrders
├── pages/          APIDemoWip, APIFinishCheck, APIFinishProposal, APIWipOrder, APIWipReconciliation,
│                   APIWipReconEntry, FinishChecks, FinishProposals, WipReconciliation, WipReconEntries, WipSetup
├── tableextensions/WipApplArea
└── tables/         FinishCheck, FinishProposal, WipReconciliation, WipReconEntry, WipSetup
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Finishing | `Prod. Order Status Management`.ChangeProdOrderStatus | The only way an order is finished; standard posting and checks apply |
| WIP | `Value Entry` filtered on order type *Production* and the order number | Consumption, capacity (item ledger entry type blank) and output cost |
| Picks | `Warehouse Activity Line`, source type `Prod. Order Component` | Open pick check |
| G/L WIP | `Inventory Posting Setup`.`WIP Account`, `G/L - Item Ledger Relation`, `G/L Entry` | WIP in G/L per order |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG WIP Control` from the enabled flag |

This feature subscribes to no Microsoft event: it only reads and calls the standard status change.

## Extending the feature

- **Add a check**: an `enumextension` on `MFG Finish Check Type` bound to an `MFG IFinishCheck` implementation.
- **Value WIP differently** (for example from G/L entries on the WIP account): implement `MFG IWipValuation` and
  call `Implement()` on `MFG WIP Locator`.
- **Read the G/L side differently** (for example from dimensions instead of the relation table): implement
  `MFG IGLWipSource` and call `ImplementGLSource()` on `MFG WIP Locator`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - WIP Control | `finishProposals` (read), `finishChecks` (read, modify), `wipOrders` (read, `evaluateFinish`, `finishOrder`, `reconcileWip`), `wipReconciliations` (read), `wipReconciliationEntries` (read) | [agent-instructions/MFG-WIP.md](agent-instructions/MFG-WIP.md) |
| Manufacturing Advanced - Demo WIP Control | `demoWipSet` (`importDemoData`) | [agent-instructions/MFG-Demo-WIP.md](agent-instructions/MFG-Demo-WIP.md) |

## Data Import

Sample data only, through `MFG Demo WIP`.Import: the three check rows, a **Suggest** and a **Reconcile** over
the company's own orders, and configuration package **MFG-WIP** with `MFG Finish Check`, `MFG Finish Proposal`
and `MFG WIP Reconciliation`. It
posts nothing, so an order appears among the proposals only if its output was really posted. The setup table is
never in the package.

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| Base Application | Microsoft | Production orders, components, routing lines, value entries, warehouse activity lines, status change |
| FEAT-CORE-001 | This app | Feature enum, facade, guided setup, MCP and configuration-package helpers |

## Known Limitations

- The reconciliation follows `G/L - Item Ledger Relation`, which is filled only when inventory cost is posted to
  G/L; with *Automatic Cost Posting* off, the difference shows as *Not posted to G/L yet* until *Post Inventory
  Cost to G/L* runs. Manual G/L journal entries on a WIP account are not attributed to any order.
- The reconciliation is rebuilt in full by **Reconcile**; earlier results live in the history, one entry per order
  and run, so two runs on the same day give two entries.
- The daily run is created at 02:00; change its time or recurrence on the job queue entry itself.
- When output or consumption is missing and checks that would catch it are off, the standard status change asks
  for confirmation in the client; without a client it answers yes.
- Proposals are rebuilt in full by **Suggest**; there is no scheduled run yet.
