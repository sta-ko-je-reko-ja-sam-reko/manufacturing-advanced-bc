# FEAT-FCL-001 - Finite Loading

Segments: **FCL-001** the load plan; **FCL-002** applying it to the production orders; **FCL-003** all work centers
at once, with the order of each routing's operations.

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, load plan, sequencing strategies and capacity source behind interfaces,
> engine, load plan page, action on the work center card, API pages, MCP configurations, sample data and
> configuration package.
> **Namespaces:** `ManufacturingAdvanced.FiniteLoading`; tests `ManufacturingAdvanced.Test`.

## Business Process

Business Central plans capacity as if it were infinite: every operation gets the dates its routing asks for, and an
overloaded work center only shows up as a load above 100 %. Finite Loading answers the question a planner actually
has: given this work center's real capacity, when will each open operation be done, and which ones will be late? It
is deliberately light: one work center, one constraint (capacity), forward loading, a swappable sequencing rule, and
a proposed plan that changes no production order until the planner applies it.

1. An administrator enables **Finite loading**. The setup starts with a 30-day horizon and sequencing by earliest due
   date.
2. On **Finite load plan** the planner picks a work center and chooses **Calculate**:
   - every operation on a firm planned or released order at that work center whose routing status is not finished is
     collected, with its remaining capacity need: the routing line's expected capacity need (in milliseconds) converted
     to the work center's capacity unit of measure with `Shop Calendar Management`.TimeFactor;
   - the **sequencing strategy** numbers them: earliest due date first, order number first in first out, or shortest
     operation first;
   - in that order, each operation is loaded day by day from the work date onto the capacity the **capacity source**
     gives for each day (by default the effective capacity of the work center's calendar entries), carrying what is
     left of a day over to the next operation.
3. Each operation shows its finite starting and ending date next to its current (infinite) dates. An operation that
   ends after its order's due date is **late**, with the days late; one that does not fit within the horizon does not
   fit and counts as late.
4. **Apply to orders (FCL-002)**, only when *Allow applying the plan to orders* is on in the setup (default off):
   every operation of the work center's plan that fits the horizon, has a planned starting date different from its
   current one and was not applied yet is moved, in plan sequence, through the **write-back** (by default
   `MFG Routing Write-Back`). It validates the routing line's *Starting Date-Time* to the planned starting date at the
   operation's current starting time, exactly as a planner would on the order's routing, so Business Central
   reschedules the operation, the operations after it and the order line, and checks reservation date conflicts. A
   moved operation is marked *Applied to order*. A finished or deleted operation is skipped.
5. **All work centers at once (FCL-003).** **Calculate all work centers** collects the open operations of every work
   center, sequences each work center with the setup's strategy, and then lets the work centers take turns loading
   their next operation. An operation is loaded only once the operations listed in its routing line's *Previous
   Operation No.* (same order, routing reference and routing) are planned, and not before the day the last of them
   ends: its *Earliest start date*. An operation after one that does not fit does not fit either; operations that
   could never be planned (a loop in the routing) are marked as not fitting. Previous operations that are not in the
   plan (finished, or on no work center) do not hold anything up. **Apply to orders** with no work center chosen
   applies every work center's plan, in the order of the planned starting dates.
6. Agents use the `mfgLoading` API group: `calculateLoad` on a work center, then `loadPlanLines`, and
   `applyLoadPlan` when a person asks for it.

## Data Model

| Table | ID | Key | Content |
|---|---|---|---|
| MFG Loading Setup | 85700 | Primary Key | `MFG Enabled`, Horizon Days, Sequencing (enum), Allow Write-Back (FCL-002) |
| MFG Load Plan Line | 85701 | Entry No. | Work center, order status and number, routing reference and number, operation, description, due date, capacity need, current starting and ending date, sequence, finite starting and ending date, fits horizon, late, days late, Written Back (FCL-002), Previous Operation No. and Earliest Start Date (FCL-003). Keys for each strategy's order, the planned start and the routing |

New field on an existing table: `Application Area Setup` 85700 *MFG Finite Loading* (tag `MFGFiniteLoading`).

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85700 | MFG Sequencing Strategy | Extensible; implements `MFG ISequencer` |
| Interface | — | MFG ISequencer | Sequence(var load plan lines) |
| Interface | — | MFG ICapacitySource | DailyCapacity(work center, date) |
| Interface | — | MFG IPlanWriteBack | Apply(load plan line): moved |
| Codeunit | 85700 | MFG Loading Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85701 | MFG Loading App Area Sub. | Application area |
| Codeunit | 85702 | MFG Loading Engine | Calculate (guarded), CalculatePlan, CalculateAll (guarded), CalculateAllPlan, ApplyPlan (guarded, needs Allow Write-Back; empty work center = all) |
| Codeunit | 85703 | MFG Calendar Capacity | Default capacity source: calendar entries' effective capacity |
| Codeunit | 85704 | MFG Loading Locator | Resolver of the capacity source (`Implement()`, `ResetCapacitySource()`) and of the write-back (`WriteBack()`, `ImplementWriteBack()`, `ResetWriteBack()`) |
| Codeunit | 85705–85707 | MFG Sequence By Due Date, MFG Sequence By Order No., MFG Sequence Shortest First | The strategies |
| Codeunit | 85708 | MFG Demo Loading | Sample data and configuration package |
| Codeunit | 85709 | MFG Routing Write-Back | Default `MFG IPlanWriteBack` |
| Page | 85700 | MFG Loading Setup | Setup card (`ApplicationArea = All`) |
| Page | 85701 | MFG Load Plan | Worksheet: work center, Calculate, Calculate all work centers, Apply to orders, Production order |
| Page | 85702 | MFG API Load Plan Line | API `loadPlanLines`, read-only |
| Page | 85703 | MFG API Loading Work Center | API `loadingWorkCenters`, bound actions `calculateLoad`, `calculateAllLoads`, `applyLoadPlan` |
| Page | 85704 | MFG API Demo Loading | API group `demoLoading`, `importDemoData` |
| Page extension | 85700 | MFG Work Center Card | *Finite load plan* on the work center card |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Operations | `Prod. Order Routing Line`, expected capacity need | The work to load |
| Capacity | `Calendar Entry`, capacity type Work Center, effective capacity | Default capacity per day |
| Units | `Shop Calendar Management`.TimeFactor | Milliseconds to the work center's unit |
| Write-back | `Prod. Order Routing Line`.Validate("Starting Date-Time") | Standard forward rescheduling of the order |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Finite Loading` |

The feature subscribes to no event. It writes nothing outside its own load plan, except when the planner applies the
plan, and then only through the routing line's own validation.

## Extending the feature

- Add a strategy, for example by customer priority or critical ratio: an `enumextension` on `MFG Sequencing
  Strategy` bound to an `MFG ISequencer` implementation.
- Take capacity from somewhere else, for example a shift plan: implement `MFG ICapacitySource` and call `Implement()`
  on `MFG Loading Locator`.
- Apply the plan differently, for example by also fixing the ending date or by scheduling manually: implement
  `MFG IPlanWriteBack` and call `ImplementWriteBack()` on `MFG Loading Locator`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Finite Loading | `loadPlanLines` (read), `loadingWorkCenters` (read, `calculateLoad`, `calculateAllLoads`, `applyLoadPlan`) | [agent-instructions/MFG-Loading.md](agent-instructions/MFG-Loading.md) |
| Manufacturing Advanced - Demo Finite Loading | `demoLoadingSet` (`importDemoData`) | [agent-instructions/MFG-Demo-Loading.md](agent-instructions/MFG-Demo-Loading.md) |

## Data Import

Sample data only: the load plan of the first work center with open operations, and configuration package
**MFG-LOADING** with the load plan lines. It changes no production order.

## Known Limitations

- **Calculate** loads one work center and ignores the order of operations; **Calculate all work centers** respects it.
  Loading is forward from the work date; wait and move times are not loaded, and a work center does not go back to
  fill a gap it left while an operation waited for its previous one.
- A successor may start on the day its previous operation ends: the plan is in days, not hours.
- Applying moves only the starting date. Business Central's own scheduling then sets the ending date from the
  infinite calendar, and moving one operation shifts the operations after it on the same order, which may be on
  other work centers; recalculate the plan after applying.
- Machine centers are loaded through their work center's calendar, not their own.
