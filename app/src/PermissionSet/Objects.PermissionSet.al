namespace ManufacturingAdvanced.Core;

permissionset 85000 "MFG Objects"
{
    Assignable = false;
    Caption = 'Manufacturing Advanced - Objects', Locked = true;

    Permissions =
        table "MFG Setup" = X,
        table "MFG Setup Step" = X,
        table "MFG Demo Data" = X,
        page "MFG Setup" = X,
        page "MFG Setup Hub" = X,
        page "MFG Feature Setup Wizard" = X,
        codeunit "MFG Setup Logic" = X,
        codeunit "MFG Feature Mgt." = X,
        codeunit "MFG Guided Setup" = X,
        codeunit "MFG Install" = X,
        codeunit "MFG Upgrade" = X,
        codeunit "MFG Default Feature Setup" = X,
        codeunit "MFG MCP Setup" = X,
        codeunit "MFG No. Series Mgt." = X,
        codeunit "MFG Config. Package Mgt." = X;
}
