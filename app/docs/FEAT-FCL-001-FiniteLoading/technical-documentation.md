# FEAT-FCL-001 - Finite Loading

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
a proposed plan that changes no production order.

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
4. Agents use the `mfgLoading` API group: `calculateLoad` on a work center, then `loadPlanLines`.

## Data Model

| Table | ID | Key | Content |
|---|---|---|---|
| MFG Loading Setup | 85700 | Primary Key | `MFG Enabled`, Horizon Days, Sequencing (enum) |
| MFG Load Plan Line | 85701 | Entry No. | Work center, order status and number, routing reference and number, operation, description, due date, capacity need, current starting and ending date, sequence, finite starting and ending date, fits horizon, late, days late. Keys for each strategy's order |

New field on an existing table: `Application Area Setup` 85700 *MFG Finite Loading* (tag `MFGFiniteLoading`).

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85700 | MFG Sequencing Strategy | Extensible; implements `MFG ISequencer` |
| Interface | — | MFG ISequencer | Sequence(var load plan lines) |
| Interface | — | MFG ICapacitySource | DailyCapacity(work center, date) |
| Codeunit | 85700 | MFG Loading Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85701 | MFG Loading App Area Sub. | Application area |
| Codeunit | 85702 | MFG Loading Engine | Calculate (guarded), CalculatePlan |
| Codeunit | 85703 | MFG Calendar Capacity | Default capacity source: calendar entries' effective capacity |
| Codeunit | 85704 | MFG Loading Locator | Resolver of the capacity source, with `Implement()` and `ResetCapacitySource()` |
| Codeunit | 85705–85707 | MFG Sequence By Due Date, MFG Sequence By Order No., MFG Sequence Shortest First | The strategies |
| Codeunit | 85708 | MFG Demo Loading | Sample data and configuration package |
| Page | 85700 | MFG Loading Setup | Setup card (`ApplicationArea = All`) |
| Page | 85701 | MFG Load Plan | Worksheet: work center, Calculate, Production order |
| Page | 85702 | MFG API Load Plan Line | API `loadPlanLines`, read-only |
| Page | 85703 | MFG API Loading Work Center | API `loadingWorkCenters`, bound action `calculateLoad` |
| Page | 85704 | MFG API Demo Loading | API group `demoLoading`, `importDemoData` |
| Page extension | 85700 | MFG Work Center Card | *Finite load plan* on the work center card |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Operations | `Prod. Order Routing Line`, expected capacity need | The work to load |
| Capacity | `Calendar Entry`, capacity type Work Center, effective capacity | Default capacity per day |
| Units | `Shop Calendar Management`.TimeFactor | Milliseconds to the work center's unit |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Finite Loading` |

The feature subscribes to no event and writes nothing outside its own load plan.

## Extending the feature

- Add a strategy, for example by customer priority or critical ratio: an `enumextension` on `MFG Sequencing
  Strategy` bound to an `MFG ISequencer` implementation.
- Take capacity from somewhere else, for example a shift plan: implement `MFG ICapacitySource` and call `Implement()`
  on `MFG Loading Locator`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Finite Loading | `loadPlanLines` (read), `loadingWorkCenters` (read, `calculateLoad`) | [agent-instructions/MFG-Loading.md](agent-instructions/MFG-Loading.md) |
| Manufacturing Advanced - Demo Finite Loading | `demoLoadingSet` (`importDemoData`) | [agent-instructions/MFG-Demo-Loading.md](agent-instructions/MFG-Demo-Loading.md) |

## Data Import

Sample data only: the load plan of the first work center with open operations, and configuration package
**MFG-LOADING** with the load plan lines. It changes no production order.

## Known Limitations

- One work center at a time, forward from the work date; operations of one order on different work centers are not
  linked to each other, and wait and move times are not loaded.
- The plan is a proposal; applying its dates to the routing lines is not part of this segment.
- Machine centers are loaded through their work center's calendar, not their own.
