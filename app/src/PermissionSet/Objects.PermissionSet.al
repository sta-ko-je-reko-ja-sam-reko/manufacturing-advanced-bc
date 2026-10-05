namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;

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
        codeunit "MFG Config. Package Mgt." = X,
        table "MFG Preflight Setup" = X,
        table "MFG Preflight Check" = X,
        table "MFG Preflight Finding" = X,
        page "MFG Preflight Setup" = X,
        page "MFG Preflight Checks" = X,
        page "MFG Preflight Findings" = X,
        page "MFG API Preflight Finding" = X,
        page "MFG API Preflight Check" = X,
        page "MFG API Preflight Order" = X,
        page "MFG API Demo Preflight" = X,
        codeunit "MFG Preflight Feature Setup" = X,
        codeunit "MFG Preflight App Area Sub." = X,
        codeunit "MFG Preflight Engine" = X,
        codeunit "MFG Preflight Reactions" = X,
        codeunit "MFG Preflight Locator" = X,
        codeunit "MFG Preflight Events" = X,
        codeunit "MFG Demo Preflight" = X,
        codeunit "MFG Preflight No Check" = X,
        codeunit "MFG Preflight Collector" = X,
        codeunit "MFG Check Routing Link" = X,
        codeunit "MFG Check Flushing Tracking" = X,
        codeunit "MFG Check Missing Bin" = X,
        codeunit "MFG Check Uncertified Design" = X;
}
