namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;

codeunit 85200 "MFG WIP Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'WIP control';
        StepDescriptionLbl: Label 'Find released production orders whose output is complete but that were never finished, see the work in progress they still hold, check what would go wrong, and finish the ones that are ready.';
        McpConfigNameTok: Label 'Manufacturing Advanced - WIP Control', Locked = true;
        McpConfigDescLbl: Label 'WIP control tools. Read the Manufacturing Advanced WIP Control agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo WIP Control', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds WIP control sample data. Read the Manufacturing Advanced Demo WIP Control agent instructions before use.';

    /// <summary>
    /// Adds the WIP control step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 30;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGWipControl;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG WIP Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the WIP control setup record.
    /// </summary>
    /// <returns>True when WIP control is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG WIP Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for WIP control. The feature numbers nothing, so the number series
    /// choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether WIP control should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG WIP Setup";
        Engine: Codeunit "MFG WIP Engine";
        DemoWip: Codeunit "MFG Demo WIP";
    begin
        EnsureSetup(Setup);
        Engine.EnsureChecks();

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoWip.Import();
    end;

    /// <summary>
    /// Creates or refreshes the WIP control MCP configurations: the functional one and the one that only
    /// seeds sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single WIP control setup record exists.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG WIP Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Reconciliation Tolerance" := 1;
        Setup."Reconciliation Days" := 30;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Finish Proposal", false, false, false);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Finish Check", false, true, false);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API WIP Order");
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API WIP Reconciliation", false, false, false);
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo WIP");
        MCPSetup.Activate(ConfigId);
    end;
}
