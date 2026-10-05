# FEAT-WIP-001 - WIP Control

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

## Data Model

### New Tables

`MFG WIP Setup` (85200), single record:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Primary Key | Code[10] | |
| 10 | MFG Enabled | Boolean | The feature switch; drives the `MFGWIPControl` application area |
| 20 | Min. Days Since Output | Integer | Days since the last output before an order is proposed. Default 0 |
| 30 | Update Unit Cost | Boolean | Passed to the standard status change. Default off |

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
| Interface | — | MFG IFinishCheck | Evaluate(order, var reason), DefaultSeverity, Description |
| Interface | — | MFG IWipValuation | Calculate(order, var proposal) |
| Codeunit | 85200 | MFG WIP Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85201 | MFG WIP App Area Sub. | Application area from the enabled flag |
| Codeunit | 85202 | MFG WIP Engine | Suggest, EvaluateOrder, FinishSelected, FinishOrder, IsOutputComplete, EnsureChecks |
| Codeunit | 85203 | MFG WIP Finish Order | Runs the standard status change for one order; isolated so `Codeunit.Run` can catch its error |
| Codeunit | 85204 | MFG WIP Value Entries | Default `MFG IWipValuation` |
| Codeunit | 85205 | MFG Demo WIP | Sample data and configuration package |
| Codeunit | 85206 | MFG Finish No Check | Default check: finds nothing, severity Off |
| Codeunit | 85207 | MFG WIP Locator | Single-instance resolver of the valuation, with `Implement()` and `ResetValuation()` |
| Codeunit | 85210 | MFG Check Missing Consumption | Check 1 |
| Codeunit | 85211 | MFG Check Open Whse. Activity | Check 2 |
| Codeunit | 85212 | MFG Check Unfinished Ops. | Check 3 |
| Page | 85200 | MFG WIP Setup | Setup card (`ApplicationArea = All`) with the checks part |
| Page | 85201 | MFG Finish Checks | ListPart |
| Page | 85202 | MFG Finish Proposals | Worksheet: Suggest, Select all ready, Finish selected, Open production order |
| Page | 85203 | MFG API Finish Proposal | API `finishProposals`, read-only |
| Page | 85204 | MFG API Finish Check | API `finishChecks`, severity writable, guarded by `CheckEnabled` |
| Page | 85205 | MFG API WIP Order | API `wipOrders` over released orders; bound actions `evaluateFinish`, `finishOrder` |
| Page | 85206 | MFG API Demo WIP | API group `demoWip`, bound action `importDemoData` |
| Page extension | 85200 | MFG Released Prod. Orders | *Finish proposals* on the released production order list |

## Files

```
app/src/WIPControl/
├── codeunits/      CheckMissingConsumption, CheckOpenWhseActivity, CheckUnfinishedOps, DemoWip,
│                   FinishNoCheck, WipAppAreaSub, WipEngine, WipFeatureSetup, WipFinishOrder,
│                   WipLocator, WipValueEntries
├── enums/          FinishCheckSeverity, FinishCheckType, FinishProposalStatus
├── interfaces/     IFinishCheck, IWipValuation
├── pageextensions/ ReleasedProdOrders
├── pages/          APIDemoWip, APIFinishCheck, APIFinishProposal, APIWipOrder, FinishChecks,
│                   FinishProposals, WipSetup
├── tableextensions/WipApplArea
└── tables/         FinishCheck, FinishProposal, WipSetup
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Finishing | `Prod. Order Status Management`.ChangeProdOrderStatus | The only way an order is finished; standard posting and checks apply |
| WIP | `Value Entry` filtered on order type *Production* and the order number | Consumption, capacity (item ledger entry type blank) and output cost |
| Picks | `Warehouse Activity Line`, source type `Prod. Order Component` | Open pick check |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG WIP Control` from the enabled flag |

This feature subscribes to no Microsoft event: it only reads and calls the standard status change.

## Extending the feature

- **Add a check**: an `enumextension` on `MFG Finish Check Type` bound to an `MFG IFinishCheck` implementation.
- **Value WIP differently** (for example from G/L entries on the WIP account): implement `MFG IWipValuation` and
  call `Implement()` on `MFG WIP Locator`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - WIP Control | `finishProposals` (read), `finishChecks` (read, modify), `wipOrders` (read, `evaluateFinish`, `finishOrder`) | [agent-instructions/MFG-WIP.md](agent-instructions/MFG-WIP.md) |
| Manufacturing Advanced - Demo WIP Control | `demoWipSet` (`importDemoData`) | [agent-instructions/MFG-Demo-WIP.md](agent-instructions/MFG-Demo-WIP.md) |

## Data Import

Sample data only, through `MFG Demo WIP`.Import: the three check rows, a **Suggest** over the company's own
released orders, and configuration package **MFG-WIP** with `MFG Finish Check` and `MFG Finish Proposal`. It
posts nothing, so an order appears among the proposals only if its output was really posted. The setup table is
never in the package.

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| Base Application | Microsoft | Production orders, components, routing lines, value entries, warehouse activity lines, status change |
| FEAT-CORE-001 | This app | Feature enum, facade, guided setup, MCP and configuration-package helpers |

## Known Limitations

- The estimated WIP comes from value entries. It is not reconciled with the G/L WIP account yet; a reconciliation
  per order against G/L is the next segment.
- When output or consumption is missing and checks that would catch it are off, the standard status change asks
  for confirmation in the client; without a client it answers yes.
- Proposals are rebuilt in full by **Suggest**; there is no scheduled run yet.
