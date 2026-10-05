namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.CostDrift;
using ManufacturingAdvanced.EngineeringChange;
using ManufacturingAdvanced.FiniteLoading;
using ManufacturingAdvanced.PlanningInsight;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.ShopFloor;
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
        tabledata "MFG WIP Reconciliation" = RIMD,
        tabledata "MFG Refresh Setup" = RIMD,
        tabledata "MFG Refresh Run" = RIMD,
        tabledata "MFG Refresh Comp. Snapshot" = RIMD,
        tabledata "MFG Refresh Oper. Snapshot" = RIMD,
        tabledata "MFG Refresh Line Snapshot" = RIMD,
        tabledata "MFG Refresh Change" = RIMD,
        tabledata "MFG Cost Drift Setup" = RIMD,
        tabledata "MFG Drift Source" = RIMD,
        tabledata "MFG Cost Drift Line" = RIMD,
        tabledata "MFG Order Variance" = RIMD,
        tabledata "MFG Planning Setup" = RIMD,
        tabledata "MFG Planning Run" = RIMD,
        tabledata "MFG Planning Message" = RIMD,
        tabledata "MFG Item Planning Insight" = RIMD,
        tabledata "MFG Planning Rule" = RIMD,
        tabledata "MFG Shop Floor Setup" = RIMD,
        tabledata "MFG Shop Floor Session" = RIMD,
        tabledata "MFG Shop Floor Event" = RIMD,
        tabledata "MFG ECO Setup" = RIMD,
        tabledata "MFG ECO Header" = RIMD,
        tabledata "MFG ECO Line" = RIMD,
        tabledata "MFG Loading Setup" = RIMD,
        tabledata "MFG Load Plan Line" = RIMD;
}
