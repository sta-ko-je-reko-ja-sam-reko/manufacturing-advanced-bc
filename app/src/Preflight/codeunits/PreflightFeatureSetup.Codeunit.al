namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;

codeunit 85100 "MFG Preflight Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Release pre-flight';
        StepDescriptionLbl: Label 'Check a production order before it is released: routing links that lead nowhere, tracked components flushed without lot or serial numbers, missing production bins, and BOMs or routings that are no longer certified.';
        McpConfigNameTok: Label 'Manufacturing Advanced - Release Pre-flight', Locked = true;
        McpConfigDescLbl: Label 'Release pre-flight tools. Read the Manufacturing Advanced Release Pre-flight agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Release Pre-flight', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds release pre-flight sample data. Read the Manufacturing Advanced Demo Release Pre-flight agent instructions before use.';

    /// <summary>
    /// Adds the release pre-flight step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 20;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGPreflight;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG Preflight Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the release pre-flight setup record.
    /// </summary>
    /// <returns>True when release pre-flight is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG Preflight Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for release pre-flight. The feature numbers nothing, so the number
    /// series choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether release pre-flight should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG Preflight Setup";
        Engine: Codeunit "MFG Preflight Engine";
        DemoPreflight: Codeunit "MFG Demo Preflight";
    begin
        EnsureSetup(Setup);
        Engine.EnsureChecks();

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoPreflight.Import();
    end;

    /// <summary>
    /// Creates or refreshes the release pre-flight MCP configurations: the functional one and the one
    /// that only seeds sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single release pre-flight setup record exists, with checking on release, blocking on
    /// errors and confirming warnings all switched on when it is first created.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG Preflight Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Check on Release" := true;
        Setup."Block on Errors" := true;
        Setup."Confirm Warnings" := true;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Preflight Finding", false, false, false);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Preflight Check", false, true, false);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Preflight Order");
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo Preflight");
        MCPSetup.Activate(ConfigId);
    end;
}
