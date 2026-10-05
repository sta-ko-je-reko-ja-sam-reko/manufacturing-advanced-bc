namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.CostDrift;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.WIPControl;

permissionset 85002 "MFG Full"
{
    Assignable = true;
    Caption = 'Manufacturing Advanced - Full', Locked = true;
    IncludedPermissionSets = "MFG Objects";

    Permissions =
        tabledata "MFG Setup" = RIMD,
        tabledata "MFG Demo Data" = RIMD,
        tabledata "MFG Preflight Setup" = RIMD,
        tabledata "MFG Preflight Check" = RIMD,
        tabledata "MFG Preflight Finding" = RIMD,
        tabledata "MFG WIP Setup" = RIMD,
        tabledata "MFG Finish Check" = RIMD,
        tabledata "MFG Finish Proposal" = RIMD,
        tabledata "MFG Refresh Setup" = RIMD,
        tabledata "MFG Refresh Run" = RIMD,
        tabledata "MFG Refresh Comp. Snapshot" = RIMD,
        tabledata "MFG Refresh Oper. Snapshot" = RIMD,
        tabledata "MFG Refresh Change" = RIMD,
        tabledata "MFG Cost Drift Setup" = RIMD,
        tabledata "MFG Drift Source" = RIMD,
        tabledata "MFG Cost Drift Line" = RIMD,
        tabledata "MFG Order Variance" = RIMD;
}
