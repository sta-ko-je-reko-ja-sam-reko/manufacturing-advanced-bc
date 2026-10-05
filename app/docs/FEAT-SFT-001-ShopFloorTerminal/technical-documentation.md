# FEAT-SFT-001 - Shop Floor Terminal

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, sessions, events, posting behind an interface, engine, terminal page and
> dialogs, action on the released production order lines, API pages with parameterised actions, MCP configurations,
> sample data and configuration package.
> **Namespaces:** `ManufacturingAdvanced.ShopFloor`; tests `ManufacturingAdvanced.Test`.

## Business Process

Standard Business Central reports production through the output journal, a desktop page made for an office, not for
an operator standing at a machine. The Shop Floor Terminal is a single page per work center where an operator starts
and stops operations and reports output, scrap and downtime, each posted at once through the standard posting.

1. An administrator enables the **Shop floor terminal**. *Post run time from the clock* starts on; default scrap and
   stop codes can be set.
2. On **Shop floor terminal** the operator picks a work center and sees its open operations on released orders.
3. **Start** opens a session for the operator on the operation; **Stop** closes it with the minutes it ran. One
   operator cannot run the same operation twice.
4. **Report output** asks for the good and scrap quantity and the scrap code. The output is posted at once, with the
   minutes clocked since the last output as run time when the setup says so; those minutes are then marked posted.
5. **Report downtime** asks for minutes and a stop code and posts them as stop time on the operation.
6. For an order line without a routing, **Report output** on the released order's lines posts output on the line.
7. Every report is recorded as an event. Agents use the `mfgShopFloor` API group: they list open operations and call
   `start`, `stop`, `reportOutput(outputQuantity, scrapQuantity, scrapCode)` and `reportDowntime(minutes, stopCode)`.

Posting builds an output journal line the way the standard Production Journal does (posting date, entry type Output,
order type Production, order, line, item, variant, location, bin, operation) and posts it with
`Item Jnl.-Post Line`.RunWithCheck. Minutes are converted to the operation's capacity unit of measure with
`Shop Calendar Management`.TimeFactor.

## Data Model

| Table | ID | Key | Content |
|---|---|---|---|
| MFG Shop Floor Setup | 85600 | Primary Key | `MFG Enabled`, Post Run Time, Default Scrap Code (→ Scrap), Default Stop Code (→ Stop) |
| MFG Shop Floor Session | 85601 | Entry No. (AutoIncrement) | Order, line, routing reference and number, operation, work center, item, operator (`EndUserIdentifiableInformation`), started and stopped at, status, minutes, run time posted |
| MFG Shop Floor Event | 85602 | Entry No. (AutoIncrement) | Type (Output, Downtime), order, line, operation, item, output and scrap quantity, scrap code, run minutes, stop minutes, stop code, reported at and by |

New field on an existing table: `Application Area Setup` 85600 *MFG Shop Floor* (tag `MFGShopFloor`).

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85600 | MFG Shop Floor Session Status | Running, Stopped |
| Enum | 85601 | MFG Shop Floor Event Type | Output, Downtime |
| Interface | — | MFG IShopFloorPosting | Post(event) |
| Codeunit | 85600 | MFG Shop Floor Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85601 | MFG Shop Floor App Area Sub. | Application area |
| Codeunit | 85602 | MFG Shop Floor Engine | StartOperation, StopOperation, ReportOperationOutput, ReportLineOutput, ReportDowntime, IsRunning |
| Codeunit | 85603 | MFG Shop Floor Journal Posting | Default posting through `Item Jnl.-Post Line` |
| Codeunit | 85604 | MFG Shop Floor Locator | Resolver of the posting, with `Implement()` and `ResetPosting()` |
| Codeunit | 85605 | MFG Demo Shop Floor | Sample data and configuration package |
| Page | 85600 | MFG Shop Floor Setup | Setup card (`ApplicationArea = All`) |
| Page | 85601 | MFG Shop Floor Terminal | Worksheet over released, unfinished routing lines, filtered by work center |
| Page | 85602 | MFG Output Dialog | Good quantity, scrap quantity, scrap code |
| Page | 85603 | MFG Downtime Dialog | Minutes, stop code |
| Page | 85604 | MFG Shop Floor Sessions | History |
| Page | 85605 | MFG Shop Floor Events | History |
| Page | 85606 | MFG API Shop Floor Operation | API `shopFloorOperations`, bound actions `start`, `stop`, `reportOutput`, `reportDowntime` |
| Page | 85607 | MFG API Shop Floor Event | API `shopFloorEvents`, read-only |
| Page | 85608 | MFG API Shop Floor Session | API `shopFloorSessions`, read-only |
| Page | 85609 | MFG API Demo Shop Floor | API group `demoShopFloor`, `importDemoData` |
| Page extension | 85600 | MFG Released Prod. Order Lines | *Report output* on a released order line |

Every engine procedure starts with the feature's `CheckEnabled`, so the UI and the API are both refused while the
feature is off.

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Posting | `Item Jnl.-Post Line`.RunWithCheck | Output, scrap, run time, stop time |
| Time units | `Shop Calendar Management`.TimeFactor | Minutes to the capacity unit of measure |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Shop Floor` |

The feature subscribes to no posting event.

## Extending the feature

Replace the posting, for example to queue reports for an MES or to post through a journal batch for review: implement
`MFG IShopFloorPosting` and call `Implement()` on `MFG Shop Floor Locator`.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Shop Floor Terminal | `shopFloorOperations` (read, actions), `shopFloorEvents`, `shopFloorSessions` (read) | [agent-instructions/MFG-ShopFloor.md](agent-instructions/MFG-ShopFloor.md) |
| Manufacturing Advanced - Demo Shop Floor Terminal | `demoShopFloorSet` (`importDemoData`) | [agent-instructions/MFG-Demo-ShopFloor.md](agent-instructions/MFG-Demo-ShopFloor.md) |

## Data Import

Sample data only: scrap code **MFG-QUAL** and stop code **MFG-BRKDN**, proposed in the setup when it has none, and
configuration package **MFG-SHOPFLOOR** with the sessions and events. It posts nothing.

## Known Limitations

- Item tracking on output is not asked for; tracked output items are reported through the standard output journal.
- Consumption is not reported from the terminal; it follows the components' flushing methods.
- The terminal is a web client page made touch-friendly, not a dedicated handheld app.
