namespace ManufacturingAdvanced.Core;

permissionset 85001 "MFG Read"
{
    Assignable = true;
    Caption = 'Manufacturing Advanced - Read', Locked = true;
    IncludedPermissionSets = "MFG Objects";

    Permissions =
        tabledata "MFG Setup" = R,
        tabledata "MFG Demo Data" = R;
}
