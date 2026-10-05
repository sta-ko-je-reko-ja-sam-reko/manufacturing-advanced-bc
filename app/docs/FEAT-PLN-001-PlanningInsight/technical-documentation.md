# FEAT-PLN-001 - Planning Insight

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup, recorded planning runs and action messages, item insights, advisors behind
> an interface, engine, reaction on *Calculate Plan - Plan. Wksh.*, pages, actions on the planning worksheet, API
> pages, MCP configurations, sample data and configuration package.
> **Namespaces:** `ManufacturingAdvanced.PlanningInsight`; tests `ManufacturingAdvanced.Test`.

## Business Process

The planning worksheet tells the planner what to do today and forgets it tomorrow. When the same items get Cancel,
Reschedule or Change Qty. messages run after run, the cause is almost always a planning parameter, but nothing in
the standard product shows the history. Planners stop trusting the worksheet. Planning Insight keeps the history and
says which parameter to look at.

1. An administrator enables **Planning insight**. The setup starts with *Record after Calculate Plan* on, a
   threshold of three runs and 90 days of history.
2. Every time **Calculate Plan** finishes on a planning worksheet batch (`OnAfterItemOnPostDataItem`), the batch's
   lines with an action message are recorded as one **planning run**: item, variant, location, action message,
   original and proposed due date and quantity, and the supply order concerned. **Record action messages** on the
   planning worksheet does the same on demand.
3. **Analyze** on *Planning insight* counts, per item over the history period, in how many runs it got any message,
   a New, a Change Qty., a Reschedule (with or without quantity change) and a Cancel. Runs are counted, not messages,
   so an item with ten messages in one run counts once.
4. Each active **rule** looks for one pattern; the first that matches gives the item its advice:
   - **Repeated rescheduling**: rescheduled in at least *threshold* runs → set, or widen, the Dampener Period.
   - **Repeated quantity changes**: changed in at least *threshold* runs → set, or raise, the Dampener Quantity.
   - **Cancel and re-create**: cancelled and given new orders in at least *threshold* runs each → lengthen the Lot
     Accumulation Period or the Rescheduling Period.
   The item's current reordering policy, dampener period and quantity, lot accumulation and rescheduling periods are
   shown next to the advice. The app changes no planning parameter.
5. Agents use the `mfgPlanning` API group to read insights and recorded messages and to switch rules on or off.

## Data Model

| Table | ID | Key | Content |
|---|---|---|---|
| MFG Planning Setup | 85500 | Primary Key | `MFG Enabled`, Record After Planning, Churn Threshold (runs), History Days |
| MFG Planning Run | 85501 | Run No. (AutoIncrement) | Worksheet template and batch, recorded at and by; FlowField Messages |
| MFG Planning Message | 85502 | Run No., Entry No. | Item, variant, location, action message, original and new due date and quantity, ref. order type and no. |
| MFG Item Planning Insight | 85503 | Item No. | Planning parameters, runs per message kind, pattern and advice, analyzed at |
| MFG Planning Rule | 85504 | Advisor | Active, Description |

New field on an existing table: `Application Area Setup` 85500 *MFG Planning Insight* (tag `MFGPlanningInsight`).

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85500 | MFG Planning Advisor Type | Extensible; implements `MFG IPlanningAdvisor`; default `MFG Planning No Advisor` |
| Interface | — | MFG IPlanningAdvisor | Evaluate(insight, threshold, var advice), Description |
| Interface | — | MFG IPlanningReactions | OnAfterCalculatePlan(template, batch) |
| Codeunit | 85500 | MFG Planning Feature Setup | `MFG IFeatureSetup` |
| Codeunit | 85501 | MFG Planning App Area Sub. | Application area |
| Codeunit | 85502 | MFG Planning Engine | RecordRun, Analyze, EnsureRules |
| Codeunit | 85503 | MFG Planning Reactions | Default reactions: record after Calculate Plan |
| Codeunit | 85504 | MFG Planning Locator | Resolver of the reactions, with `Implement()` |
| Codeunit | 85505 | MFG Planning Events | Subscriber proxy on the Calculate Plan report |
| Codeunit | 85506 | MFG Demo Planning | Sample data and configuration package |
| Codeunit | 85507 | MFG Planning No Advisor | Default advisor |
| Codeunit | 85510–85512 | MFG Advise Reschedules, MFG Advise Quantity Changes, MFG Advise Cancel And New | The three rules |
| Page | 85500 | MFG Planning Setup | Setup card (`ApplicationArea = All`) with the rules part |
| Page | 85501 | MFG Planning Rules | ListPart |
| Page | 85502 | MFG Planning Runs | Recorded runs |
| Page | 85503 | MFG Planning Messages | Recorded action messages |
| Page | 85504 | MFG Item Planning Insights | *Planning insight*: Analyze, Item card, Recorded runs |
| Page | 85505–85507 | MFG API Planning Insight / Message / Rule | `itemPlanningInsights`, `planningMessages` (read-only), `planningRules` (active writable, guarded) |
| Page | 85508 | MFG API Demo Planning | API group `demoPlanning`, `importDemoData` |
| Page extension | 85500 | MFG Planning Worksheet | *Record action messages*, *Planning insight* |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| After planning | Report `Calculate Plan - Plan. Wksh.`.`OnAfterItemOnPostDataItem` | Proxy → locator → reactions → `RecordRun`. `SkipOnMissingLicense` and `SkipOnMissingPermission` on |
| Worksheet | `Requisition Line`, type Item, action message not blank | The recorded lines |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Planning Insight` |

## Extending the feature

Add a rule, for example one that flags items planned on Lot-for-Lot with many small New orders: an `enumextension` on
`MFG Planning Advisor Type` bound to an `MFG IPlanningAdvisor` implementation.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Planning Insight | `itemPlanningInsights`, `planningMessages` (read), `planningRules` (read, modify) | [agent-instructions/MFG-Planning.md](agent-instructions/MFG-Planning.md) |
| Manufacturing Advanced - Demo Planning Insight | `demoPlanningSet` (`importDemoData`) | [agent-instructions/MFG-Demo-Planning.md](agent-instructions/MFG-Demo-Planning.md) |

## Data Import

Sample data only: the rules, a recording of the action messages already on each planning worksheet batch of the
company (at most once per batch and day), an analysis, and configuration package **MFG-PLANNING** with the rules,
runs, messages and insights. It does not run planning. The setup table is never in the package.

## Known Limitations

- Only planning worksheet batches are recorded; the requisition worksheet is not.
- History is never purged automatically yet; the analysis only looks at the history period.
- Advice only; the app changes no planning parameter.
