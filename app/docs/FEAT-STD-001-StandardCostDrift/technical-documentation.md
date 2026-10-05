# FEAT-STD-001 - Standard Cost Drift

Segments: **STD-001** roll-up and last purchase price, worksheet, order variances; **STD-002** purchase price lists.

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, drift sources behind an interface, drift lines, order variances, engine,
> pages, action on the standard cost worksheet, API pages, MCP configurations, sample data and configuration
> package.
> **Namespaces:** `ManufacturingAdvanced.CostDrift`; tests `ManufacturingAdvanced.Test`.

## Business Process

Standard costs go stale silently. When a BOM, routing, work-centre cost or purchase price changes and nobody rolls
up the standard cost, every production order posts a variance, each one correct and none of them telling anyone
what to do. Standard Cost Drift finds the items whose standard no longer matches reality, hands the new costs to
the **standard cost worksheet** the standard product already has, and shows finished orders' variances by type.

1. An administrator enables **Standard cost drift**. The setup starts with a 2 % tolerance and a 30-day variance
   period; the worksheet name is filled in (`MFG-DRIFT`) the first time a line is sent.
2. **Calculate** on *Standard cost drift* asks every active **source** for a proposed standard cost:
   - **BOM and routing roll-up**: every standard-cost item replenished by production order or assembly is rolled up
     with the standard `Calculate Standard Cost`.`CalcItems` into a temporary item, exactly as *Roll Up Standard
     Cost* does, without changing any item.
   - **Last purchase price**: every purchased standard-cost item that has been bought proposes its last direct cost.
   - **Purchase price list** (STD-002): every purchased standard-cost item with an active purchase price valid on the
     work date (`Price List Line`: price type Purchase, local currency, no variant, minimum quantity up to 1, not a
     discount line) proposes that price per base unit of measure — its own vendor's (`Item`.`Vendor No.`) when there
     is one, otherwise the lowest. It replaces the last purchase price for the same item, because it is what the item
     will cost from now on.
   Each item whose proposal differs from its current standard by at least the tolerance is listed with the drift
   amount and percentage. When two sources price the same item, the first source in the enum wins, except that a
   price list price replaces a last purchase price.
3. The cost accountant selects lines and chooses **Send to worksheet**. Each line is written to the standard cost
   worksheet named in the setup, created when missing, through the source that proposed it:
   - a roll-up line with every single-level and rolled-up cost share, as *Roll Up Standard Cost* writes it;
   - a purchase price line with the new standard cost validated, as *Suggest Item Standard Cost* writes it.
   Nothing changes on an item until the worksheet is implemented with the standard **Implement Standard Cost
   Changes**.
4. **Order variances** lists the production orders finished within the variance period with their output cost and
   their material, capacity, capacity overhead, manufacturing overhead and subcontracted variances, from the value
   entries posted by cost adjustment.
5. Agents use the `mfgCostDrift` API group: they read drift lines and order variances, switch sources on or off, and
   call `sendToWorksheet` on a drift line.

## Data Model

| Table | ID | Key | Content |
|---|---|---|---|
| MFG Cost Drift Setup | 85300 | Primary Key | `MFG Enabled`, Tolerance %, Worksheet Name (→ Standard Cost Worksheet Name), Variance Days |
| MFG Drift Source | 85301 | Source | Active, Description |
| MFG Cost Drift Line | 85302 | Item No. | Source, description, replenishment system, current and proposed standard cost, drift amount and %, last cost calculation date, Selected, Sent to worksheet, Calculated At |
| MFG Order Variance | 85303 | Prod. Order No. | Item, description, finished date, output cost, five variances by type, total, variance % of output cost |

New field on an existing table: `Application Area Setup` 85300 *MFG Cost Drift* (tag `MFGCostDrift`).

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85300 | MFG Drift Source Type | Extensible; implements `MFG IDriftSource`; default `MFG Drift No Source` |
| Interface | — | MFG IDriftSource | Collect, TransferToWorksheet, Description |
| Codeunit | 85300 | MFG Cost Drift Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85301 | MFG Cost Drift App Area Sub. | Application area from the enabled flag |
| Codeunit | 85302 | MFG Cost Drift Engine | Calculate, TransferSelected, TransferLine, CalculateVariances, EnsureSources, EnsureWorksheet |
| Codeunit | 85303 | MFG Drift No Source | Default source: proposes nothing |
| Codeunit | 85304 | MFG Drift Roll-up | Source: `Calculate Standard Cost`.CalcItems |
| Codeunit | 85305 | MFG Drift Purchase Price | Source: last direct cost |
| Codeunit | 85307 | MFG Drift Price List | Source: current purchase price list price (STD-002) |
| Codeunit | 85306 | MFG Demo Cost Drift | Sample data and configuration package |
| Page | 85300 | MFG Cost Drift Setup | Setup card (`ApplicationArea = All`) with the sources part |
| Page | 85301 | MFG Drift Sources | ListPart |
| Page | 85302 | MFG Cost Drift | Calculate, Send to worksheet, Standard cost worksheet, Order variances |
| Page | 85303 | MFG Order Variances | Calculate |
| Page | 85304 | MFG API Cost Drift Line | API `costDriftLines`, read-only, bound action `sendToWorksheet` (guarded by `CheckEnabled`) |
| Page | 85305 | MFG API Drift Source | API `driftSources`, Active writable, guarded |
| Page | 85306 | MFG API Order Variance | API `orderVariances`, read-only |
| Page | 85307 | MFG API Demo Cost Drift | API group `demoCostDrift`, bound action `importDemoData` |
| Page extension | 85300 | MFG Std. Cost Worksheet | *Standard cost drift* on the standard cost worksheet |

## Files

```
app/src/CostDrift/
├── codeunits/      CostDriftAppAreaSub, CostDriftEngine, CostDriftFeatureSetup, DemoCostDrift, DriftNoSource,
│                   DriftPriceList, DriftPurchasePrice, DriftRollUp
├── enums/          DriftSourceType
├── interfaces/     IDriftSource
├── pageextensions/ StdCostWorksheet
├── pages/          APICostDriftLine, APIDemoCostDrift, APIDriftSource, APIOrderVariance, CostDrift, CostDriftSetup,
│                   DriftSources, OrderVariances
├── tableextensions/CostDriftApplArea
└── tables/         CostDriftLine, CostDriftSetup, DriftSource, OrderVariance
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Roll-up | `Calculate Standard Cost`.SetProperties, CalcItems | Into a temporary item; no item is changed |
| Worksheet | `Standard Cost Worksheet`, `Standard Cost Worksheet Name` | Lines written the way the two standard reports write them; implemented by the standard report |
| Variances | `Value Entry`, order type *Production*, entry type *Variance*, by variance type | Posted by *Adjust Cost - Item Entries* |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Cost Drift` from the enabled flag |

The feature subscribes to no Microsoft event and changes no cost itself.

## Extending the feature

Add a source, for example the item's average cost, a supplier price list, or a planned future BOM version: an
`enumextension` on `MFG Drift Source Type` bound to an `MFG IDriftSource` implementation.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Standard Cost Drift | `costDriftLines` (read, `sendToWorksheet`), `driftSources` (read, modify), `orderVariances` (read) | [agent-instructions/MFG-CostDrift.md](agent-instructions/MFG-CostDrift.md) |
| Manufacturing Advanced - Demo Standard Cost Drift | `demoCostDriftSet` (`importDemoData`) | [agent-instructions/MFG-Demo-CostDrift.md](agent-instructions/MFG-Demo-CostDrift.md) |

## Data Import

Sample data only, through `MFG Demo Cost Drift`.Import: the source configuration, the standard cost worksheet, a
drift calculation and a variance calculation over the company's own items and finished orders, and configuration
package **MFG-COSTDRIFT** with the sources, drift lines and order variances. It changes no item cost and posts nothing.
The setup table is never in the package.

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| Base Application | Microsoft | Items, Calculate Standard Cost, standard cost worksheet, value entries, production orders |
| FEAT-CORE-001 | This app | Feature enum, facade, guided setup, MCP and configuration-package helpers |

## Known Limitations

- The roll-up runs over all standard-cost manufactured and assembled items at once. An item that cannot be rolled up,
  for example because its BOM is not certified, stops the calculation with the standard error, as *Roll Up Standard
  Cost* does.
- Variances appear only after *Adjust Cost - Item Entries* has run for the finished orders.
- Purchase prices come from the last direct cost and from price lists; blanket orders are not a source. Prices in a
  foreign currency, for a variant or from a minimum quantity above 1 are not used.
