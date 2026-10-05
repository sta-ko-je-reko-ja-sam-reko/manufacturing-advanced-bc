namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;

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
        tabledata "MFG Preflight Finding" = R;
}
