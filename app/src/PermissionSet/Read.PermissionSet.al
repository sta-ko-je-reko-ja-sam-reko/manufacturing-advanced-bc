namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.CostDrift;
using ManufacturingAdvanced.EngineeringChange;
using ManufacturingAdvanced.FiniteLoading;
using ManufacturingAdvanced.PlanningInsight;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.ShopFloor;
using ManufacturingAdvanced.WIPControl;

permissionset 85001 "MFG Read"
{
    Assignable = true;
    Caption = 'Manufacturing Advanced - Read', Locked = true;
    IncludedPermissionSets = "MFG Objects";

    Permissions =
        tabledata "MFG Setup" = R,
        tabledata "MFG Demo Data" = R,
        tabledata "MFG Preflight Setup" = R,
        tabledata "MFG Preflight Check" = R,
        tabledata "MFG Preflight Finding" = R,
        tabledata "MFG WIP Setup" = R,
        tabledata "MFG Finish Check" = R,
        tabledata "MFG Finish Proposal" = R,
        tabledata "MFG WIP Reconciliation" = R,
        tabledata "MFG Refresh Setup" = R,
        tabledata "MFG Refresh Run" = R,
        tabledata "MFG Refresh Comp. Snapshot" = R,
        tabledata "MFG Refresh Oper. Snapshot" = R,
        tabledata "MFG Refresh Change" = R,
        tabledata "MFG Cost Drift Setup" = R,
        tabledata "MFG Drift Source" = R,
        tabledata "MFG Cost Drift Line" = R,
        tabledata "MFG Order Variance" = R,
        tabledata "MFG Planning Setup" = R,
        tabledata "MFG Planning Run" = R,
        tabledata "MFG Planning Message" = R,
        tabledata "MFG Item Planning Insight" = R,
        tabledata "MFG Planning Rule" = R,
        tabledata "MFG Shop Floor Setup" = R,
        tabledata "MFG Shop Floor Session" = R,
        tabledata "MFG Shop Floor Event" = R,
        tabledata "MFG ECO Setup" = R,
        tabledata "MFG ECO Header" = R,
        tabledata "MFG ECO Line" = R,
        tabledata "MFG Loading Setup" = R,
        tabledata "MFG Load Plan Line" = R;
}
