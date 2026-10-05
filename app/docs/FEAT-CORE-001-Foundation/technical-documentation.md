# FEAT-CORE-001 - Foundation

> **Source/legacy reference:** N/A (greenfield).
> **Affected objects:** foundation setup, feature enum and facade, guided setup hub and wizard, install and
> upgrade, MCP, configuration package and number series helpers, permission sets.
> **Namespaces:** `ManufacturingAdvanced.Core`; tests `ManufacturingAdvanced.Test`.

## Business Process

1. On installation, and again on every upgrade, the app creates its single foundation setup record,
   registers the guided setup on Microsoft's *Assisted Setup* list, and asks every feature to create or
   refresh its MCP configuration.
2. An administrator opens the guided setup. The hub lists the foundation as step 10 and then one step per
   feature, each with a status derived from live data: a feature is *Completed* when it is enabled; the
   foundation is *Completed* when its record exists. Nothing about onboarding is stored.
3. Choosing a step opens the wizard for it: an introduction, then the choices (enable the feature, create
   its number series, load sample data), then *Finish*. Finishing applies the choices through the feature's
   own implementation and refreshes the application areas, but does not restart the session.
4. When the hub closes it marks the assisted setup complete and compares an enabled-state fingerprint taken
   on open with one taken on close. If any feature changed, the session restarts once so the application
   areas take effect.
5. A feature's sample data seeder may build that feature's configuration package through
   `MFG Config. Package Mgt.`, only when the user chose to load sample data.

## Data Model

### New Tables

`MFG Setup` (85000), the single foundation record:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Primary Key | Code[10] | Always blank. The foundation holds no feature settings |

`MFG Setup Step` (85001), `TableType = Temporary`, the guided setup buffer:

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Step No. | Integer | Primary key and display order. The foundation is 10 |
| 2 | Feature | Enum `MFG Feature` | The feature the step configures |
| 3 | Has Toggle | Boolean | False for the foundation |
| 4 | Has No. Series | Boolean | Whether the wizard offers to create numbering |
| 10 | Name | Text[100] | |
| 11 | Description | Text[250] | |
| 12 | Setup Page ID | Integer | The feature's full setup page |
| 20 | Enabled | Boolean | Current state, for display |
| 30 | Status | Enum `MFG Setup Step Status` | Derived, never stored |

`MFG Demo Data` (85002), the shared, deliberately empty source table of every feature's demo import API page.

### New Fields on Existing Tables

None.

## Objects

| Type | ID | Name | Namespace | Purpose |
|---|---|---|---|---|
| Table | 85000 | MFG Setup | ManufacturingAdvanced.Core | Foundation record, with a `Logic()`/`Define()` resolver over `MFG ISetup` |
| Table | 85001 | MFG Setup Step | ManufacturingAdvanced.Core | Temporary guided setup buffer |
| Table | 85002 | MFG Demo Data | ManufacturingAdvanced.Core | Source of the demo import API pages |
| Enum | 85000 | MFG Feature | ManufacturingAdvanced.Core | Extensible; implements `MFG IFeatureSetup`; default `MFG Default Feature Setup` |
| Enum | 85001 | MFG Setup Step Status | ManufacturingAdvanced.Core | Not started, In progress, Completed |
| Interface | — | MFG IFeatureSetup | ManufacturingAdvanced.Core | RegisterStep, IsEnabled, ApplyChoices, RegisterMcpConfiguration |
| Interface | — | MFG ISetup | ManufacturingAdvanced.Core | EnsureExists, IsComplete |
| Codeunit | 85000 | MFG Setup Logic | ManufacturingAdvanced.Core | Default `MFG ISetup` |
| Codeunit | 85001 | MFG Feature Mgt. | ManufacturingAdvanced.Core | Public, single-instance facade: IsEnabled, CheckEnabled, RefreshExperienceAreas, RestartSession, ApplyExperienceChange, GetEnabledFingerprint |
| Codeunit | 85002 | MFG Guided Setup | ManufacturingAdvanced.Core | Internal orchestration of the hub and wizard; assisted setup registration |
| Codeunit | 85003 | MFG Install | ManufacturingAdvanced.Core | Install: setup record, assisted setup, MCP configurations |
| Codeunit | 85004 | MFG Upgrade | ManufacturingAdvanced.Core | Upgrade: the same three steps, idempotent |
| Codeunit | 85005 | MFG Default Feature Setup | ManufacturingAdvanced.Core | No-op `MFG IFeatureSetup` for values without their own implementation |
| Codeunit | 85006 | MFG MCP Setup | ManufacturingAdvanced.Core | EnsureConfigurations, EnsureConfiguration, EnsureApiTool, EnsureActionTool, Activate |
| Codeunit | 85007 | MFG No. Series Mgt. | ManufacturingAdvanced.Core | EnsureSeries: create a number series once |
| Codeunit | 85008 | MFG Config. Package Mgt. | ManufacturingAdvanced.Core | CreatePackage, AddOwnTable, AddExtendedTable |
| Page | 85000 | MFG Setup | ManufacturingAdvanced.Core | Foundation card; opens the guided setup |
| Page | 85001 | MFG Setup Hub | ManufacturingAdvanced.Core | List over the step buffer; the registered assisted setup; owns the single restart |
| Page | 85002 | MFG Feature Setup Wizard | ManufacturingAdvanced.Core | NavigatePage, parameterised by step |
| Permission set | 85000 | MFG Objects | ManufacturingAdvanced.Core | Execute on every object; not assignable |
| Permission set | 85001 | MFG Read | ManufacturingAdvanced.Core | Read access |
| Permission set | 85002 | MFG Full | ManufacturingAdvanced.Core | Full access |

All enablement UI (setup page, hub, wizard) is `ApplicationArea = All`, so it is reachable on a fresh tenant
where every feature is still off.

## Files

```
app/src/
├── Core/
│   ├── codeunits/  ConfigPackageMgt, DefaultFeatureSetup, FeatureMgt, GuidedSetup, Install,
│   │               MCPSetup, NoSeriesMgt, SetupLogic, Upgrade
│   ├── enums/      Feature, SetupStepStatus
│   ├── interfaces/ IFeatureSetup, ISetup
│   ├── pages/      FeatureSetupWizard, Setup, SetupHub
│   └── tables/     DemoData, Setup, SetupStep
└── PermissionSet/  Full, Objects, Read
```

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Assisted Setup | `Guided Experience`.InsertAssistedSetup / CompleteAssistedSetup | Registers and completes the hub |
| Application areas | `Application Area Mgmt. Facade`.RefreshExperienceTierCurrentCompany | Applies a changed `Enabled` flag |
| MCP | `MCP Config` (System.MCP) | Configurations and API tools per feature. BC 29 replaces the two-argument `GetAPIToolId` with an overload taking the object type |
| RapidStart | `Config. Package Management` (System.IO) | InsertPackage, InsertPackageTable; field inclusion on `Config. Package Field` |

## Extending the foundation

- **Add a feature** (in this app or a dependent app): add a value to `MFG Feature` (or an `enumextension`
  value) bound to a codeunit implementing `MFG IFeatureSetup`.
- **Replace the setup logic**: call `Define()` on `MFG Setup` with another `MFG ISetup` implementation.

## Dependencies

| Dependency | App | Usage |
|---|---|---|
| System Application, Base Application | Microsoft | Guided Experience, application areas, MCP Config, Config. Package Management, No. Series |

## Known Limitations

- The foundation itself creates no MCP configuration; each feature registers its own (Release Pre-flight is the first).
- The foundation ships no role centre. One is added when there are features with something to show.
