namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;
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
        tabledata "MFG Finish Proposal" = RIMD;
}
