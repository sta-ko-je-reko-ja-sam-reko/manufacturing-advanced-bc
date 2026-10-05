namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;
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
        tabledata "MFG Finish Proposal" = R;
}
