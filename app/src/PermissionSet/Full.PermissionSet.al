namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;

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
        tabledata "MFG Preflight Finding" = RIMD;
}
