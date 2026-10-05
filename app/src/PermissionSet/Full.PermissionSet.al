namespace ManufacturingAdvanced.Core;

permissionset 85002 "MFG Full"
{
    Assignable = true;
    Caption = 'Manufacturing Advanced - Full', Locked = true;
    IncludedPermissionSets = "MFG Objects";

    Permissions =
        tabledata "MFG Setup" = RIMD,
        tabledata "MFG Demo Data" = RIMD;
}
