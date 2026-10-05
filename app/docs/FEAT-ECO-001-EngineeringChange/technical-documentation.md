# FEAT-ECO-001 - Engineering Change

Segments: **ECO-001** change orders, versions, approval on the card, impact; **ECO-002** approval through Business
Central approval workflows.

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** feature setup with a number series, engineering change orders and lines, object types
> behind an interface, header logic behind an interface, engine, impact, document pages, API pages, MCP
> configurations, sample data and configuration package.
> **Namespaces:** `ManufacturingAdvanced.EngineeringChange`; tests `ManufacturingAdvanced.Test`.

## Business Process

Business Central has BOM and routing versions with a status and a starting date, but no change document, no approval
and no view of what a change affects. In practice versions are edited and certified by whoever has the permission, on
whatever day. An engineering change order puts a reason, an approval and an effective date around it.

1. An administrator enables **Engineering change**. The wizard can create number series **MFG-ECO** (ECO00001–ECO99999);
   *Approver must differ from requester* starts on.
2. A user creates an **engineering change order**: description, reason, effective date, and one line per production
   BOM or routing that changes, with what changes.
3. **Create versions** creates, per line, a new version named after the change, with status *Under Development*, as a
   copy of the version certified for today (or of the BOM or routing itself) made with the standard *Production
   BOM-Copy* or *Routing Line-Copy Lines*. The user edits the new versions from the line.
4. **Send for approval** needs an effective date and a new version on every line. What follows depends on the
   setup's **Approval method**, an extensible enum bound to `MFG IEcoApproval`:
   - **On the change card** (default): the change is pending approval; **Approve** or **Reject** follows on the card;
     with a separate approver required, the requester cannot decide. **Reopen** returns a pending or rejected change
     to open.
   - **Approval workflow** (ECO-002): the app raises the workflow event *Approval of an engineering change is
     requested* through `Workflow Management`.HandleEvent; it is refused when no enabled workflow starts with that
     event. The workflow, normally created from the template **Engineering change approval workflow** (category
     *Manufacturing*, built with the standard `Workflow Setup`.InsertDocApprovalWorkflowSteps), restricts the record,
     sets it to pending approval, and creates and sends approval requests. Approvers decide in **Requests to Approve**;
     **Approve** and **Reject** on the card are refused. When the last approver approves, the standard *Release
     Document* response approves the change, recording that approver. A rejection, or **Reopen** (which raises *An
     approval request for an engineering change is canceled*), runs the standard *Open Document* response: the change
     is open again, as standard documents are, and the approval entries keep the rejection. **Approvals** on the card
     shows the entries.
   The standard responses reach the change through events Microsoft provides for other tables
   (`Approvals Mgmt`.OnSetStatusToPendingApproval, `Workflow Response Handling`.OnReleaseDocument / OnOpenDocument),
   and the approval entry gets the change number through `Approvals Mgmt`.OnPopulateApprovalEntryArgument. The app
   publishes no event of its own.
5. **Implement** sets each new version's starting date to the effective date and certifies it, which runs the standard
   BOM or routing check. Orders refreshed from that date on use the new versions.
6. **Impact** lists the planned, firm planned and released production order lines that use any BOM or routing the
   change touches, with the version they were calculated with.
7. Only an open or rejected change can be deleted; the versions it created stay with their BOM or routing.
8. Agents use the `mfgEco` API group to create changes and lines and to call `createVersions` and `submitForApproval`.
   Approval and implementation are deliberately not exposed: a person decides those in Business Central.

## Data Model

| Table | ID | Key | Content |
|---|---|---|---|
| MFG ECO Setup | 85800 | Primary Key | `MFG Enabled`, ECO Nos. (→ No. Series), Separate Approver, Approval Method (ECO-002) |
| MFG ECO Header | 85801 | No. | Description, reason, status, effective date, requested by and at, approved by and at, implemented at; FlowField Lines. `OnInsert` and `OnDelete` delegate to `MFG IEcoHeader` through `Logic()`/`Define()` |
| MFG ECO Line | 85802 | ECO No., Line No. | Object type, no. (`OnValidate` delegates to the object type's `MFG IEcoObject`), description, new version code, what changes |
| MFG ECO Impact | 85803 | Entry No. | `TableType = Temporary`: object, order status, order, line, item, quantity, due date, version in use |

New field on an existing table: `Application Area Setup` 85800 *MFG Engineering Change* (tag `MFGEngineeringChange`).

## Objects

| Type | ID | Name | Purpose |
|---|---|---|---|
| Enum | 85800 | MFG ECO Status | Open, Pending approval, Approved, Implemented, Rejected |
| Enum | 85801 | MFG ECO Object Type | Extensible; implements `MFG IEcoObject`; default `MFG ECO No Object` |
| Enum | 85802 | MFG ECO Approval Method | Extensible; implements `MFG IEcoApproval`: On the change card, Approval workflow |
| Interface | — | MFG IEcoApproval | Submit, CheckDirectDecision, Cancel |
| Interface | — | MFG IEcoObject | ValidateNo, CreateVersion, Certify, CollectImpact, OpenVersion |
| Interface | — | MFG IEcoHeader | Trigger_OnInsert, Trigger_OnDelete |
| Codeunit | 85800 | MFG ECO Feature Setup | `MFG IFeatureSetup`, with the number series |
| Codeunit | 85801 | MFG ECO App Area Sub. | Application area |
| Codeunit | 85802 | MFG ECO Engine | CreateVersions, SubmitForApproval, Approve, Reject, Reopen, Implement, GetImpact; MarkPendingApproval, MarkApproved, MarkRejected, MarkOpen for the approval methods |
| Codeunit | 85803 | MFG ECO Header Logic | Default `MFG IEcoHeader`: numbering, requester, delete rule |
| Codeunit | 85804 | MFG ECO No Object | Default object type |
| Codeunit | 85805 | MFG ECO Production BOM | Object type: production BOM |
| Codeunit | 85806 | MFG ECO Routing | Object type: routing |
| Codeunit | 85807 | MFG Demo ECO | Sample data and configuration package |
| Codeunit | 85808 | MFG ECO Built-in Approval | Default `MFG IEcoApproval`: on the card, separate approver rule |
| Codeunit | 85809 | MFG ECO Workflow Approval | `MFG IEcoApproval` through approval workflows |
| Codeunit | 85810 | MFG ECO Workflow Mgt. | Event codes, event library and combinations, workflow template, approval entry, the three status responses |
| Codeunit | 85811 | MFG ECO Workflow Events | Subscriber proxy for the workflow and approval events, one line each |
| Page | 85800 | MFG ECO Setup | Setup card (`ApplicationArea = All`) |
| Page | 85801 | MFG ECO List | Engineering change orders |
| Page | 85802 | MFG ECO Card | Document with the approval actions and **Approvals** (approval entries) |
| Page | 85803 | MFG ECO Subform | Lines; drill down on the new version opens it |
| Page | 85804 | MFG ECO Impact | Impact over the temporary table |
| Page | 85805 | MFG API ECO | API `engineeringChanges`, writable (guarded), actions `createVersions`, `submitForApproval` |
| Page | 85806 | MFG API ECO Line | API `engineeringChangeLines`, writable while the change is open (guarded) |
| Page | 85807 | MFG API Demo ECO | API group `demoEco`, `importDemoData` |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Numbering | `No. Series`.GetNextNo | Engineering change numbers |
| Versions | `Production BOM-Copy`.CopyBOM, `Routing Line-Copy Lines`.CopyRouting, `VersionManagement`.GetBOMVersion / GetRtngVersion | New version as a copy of the one in use |
| Certification | `Production BOM Version` / `Routing Version` Status validation | Runs the standard checks |
| Workflow events | `Workflow Event Handling`.OnAddWorkflowEventsToLibrary, `Workflow Setup`.OnAfterInitWorkflowTemplates | Event library and template (ECO-002) |
| Workflow responses | `Approvals Mgmt`.OnSetStatusToPendingApproval, `Workflow Response Handling`.OnReleaseDocument / OnOpenDocument | Status of the change (ECO-002) |
| Approval entries | `Approvals Mgmt`.OnPopulateApprovalEntryArgument | Document No. of the entry (ECO-002) |
| Application areas | `Application Area Mgmt. Facade`.`OnGetEssentialExperienceAppAreas` | `MFG Engineering Change` |

## Extending the feature

- Add an object type, for example an assembly BOM or an item's routing assignment: an `enumextension` on
  `MFG ECO Object Type` bound to an `MFG IEcoObject` implementation.
- Replace numbering or the delete rule: call `Define()` on `MFG ECO Header` with another `MFG IEcoHeader`.
- Approve another way, for example through Power Automate: an `enumextension` on `MFG ECO Approval Method` bound to an
  `MFG IEcoApproval` implementation.

## MCP configurations

| Configuration | Tools | Agent instructions |
|---|---|---|
| Manufacturing Advanced - Engineering Change | `engineeringChanges` (read, create, modify, actions), `engineeringChangeLines` (read, create, modify, delete) | [agent-instructions/MFG-ECO.md](agent-instructions/MFG-ECO.md) |
| Manufacturing Advanced - Demo Engineering Change | `demoEcoSet` (`importDemoData`) | [agent-instructions/MFG-Demo-ECO.md](agent-instructions/MFG-Demo-ECO.md) |

## Data Import

Sample data only: the number series when the setup has none, open change **ECO-DEMO-01** effective a month from the
work date on the production BOM of the first certified manufactured item, with its new version under development,
and configuration package **MFG-ECO** with the change headers and lines. Nothing is certified.

## Known Limitations

- Under an approval workflow a rejected change returns to *Open*, not *Rejected*, as Business Central does for its own
  documents; the rejection is on the approval entries.
- The workflow template is created when Business Central initializes its workflows (opening **Workflows** or
  **Workflow Templates**). Its approver defaults to the requester's direct approver in **Approval User Setup**.
- The impact lists orders; it does not refresh them. Refresh the orders after the effective date to use the new
  versions.
- The new version's code is the change number, so one change creates at most one version per BOM or routing.
