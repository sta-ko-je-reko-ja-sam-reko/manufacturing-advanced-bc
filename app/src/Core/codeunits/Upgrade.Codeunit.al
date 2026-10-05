namespace ManufacturingAdvanced.Core;

codeunit 85004 "MFG Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Setup: Record "MFG Setup";
        GuidedSetup: Codeunit "MFG Guided Setup";
        MCPSetup: Codeunit "MFG MCP Setup";
    begin
        Setup.EnsureExists();
        GuidedSetup.RegisterAssistedSetup();
        MCPSetup.EnsureConfigurations();
    end;
}
