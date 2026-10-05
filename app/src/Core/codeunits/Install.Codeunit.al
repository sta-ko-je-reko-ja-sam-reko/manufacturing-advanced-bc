namespace ManufacturingAdvanced.Core;

codeunit 85003 "MFG Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
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
