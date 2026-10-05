namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;

codeunit 85400 "MFG Refresh Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Refresh protection';
        StepDescriptionLbl: Label 'Record what every refresh of a production order changes in its components and operations, including the changes a planner made by hand, and put them back with one action.';
        McpConfigNameTok: Label 'Manufacturing Advanced - Refresh Protection', Locked = true;
        McpConfigDescLbl: Label 'Refresh protection tools. Read the Manufacturing Advanced Refresh Protection agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Refresh Protection', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds refresh protection sample data. Read the Manufacturing Advanced Demo Refresh Protection agent instructions before use.';

    /// <summary>
    /// Adds the refresh protection step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 40;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGRefreshGuard;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG Refresh Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the refresh protection setup record.
    /// </summary>
    /// <returns>True when refresh protection is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG Refresh Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for refresh protection. The feature numbers nothing, so the number
    /// series choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether refresh protection should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG Refresh Setup";
        DemoRefresh: Codeunit "MFG Demo Refresh";
    begin
        EnsureSetup(Setup);

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoRefresh.Import();
    end;

    /// <summary>
    /// Creates or refreshes the refresh protection MCP configurations: the functional one and the one that only
    /// seeds sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single refresh protection setup record exists, with notifications switched on.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG Refresh Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Notify on Changes" := true;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Refresh Run", false, false, false);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Refresh Change");
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo Refresh");
        MCPSetup.Activate(ConfigId);
    end;
}
