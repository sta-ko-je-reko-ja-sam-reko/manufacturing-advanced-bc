namespace ManufacturingAdvanced.CostDrift;

using ManufacturingAdvanced.Core;

codeunit 85300 "MFG Cost Drift Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Standard cost drift';
        StepDescriptionLbl: Label 'Find standard-cost items whose standard no longer matches their BOM, routing or purchase price, send the new costs to a standard cost worksheet, and see the variances of finished production orders by type.';
        McpConfigNameTok: Label 'Manufacturing Advanced - Standard Cost Drift', Locked = true;
        McpConfigDescLbl: Label 'Standard cost drift tools. Read the Manufacturing Advanced Standard Cost Drift agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Standard Cost Drift', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds standard cost drift sample data. Read the Manufacturing Advanced Demo Standard Cost Drift agent instructions before use.';

    /// <summary>
    /// Adds the standard cost drift step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 50;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGCostDrift;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG Cost Drift Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the standard cost drift setup record.
    /// </summary>
    /// <returns>True when standard cost drift is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG Cost Drift Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for standard cost drift. The feature numbers nothing, so the number
    /// series choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether standard cost drift should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG Cost Drift Setup";
        Engine: Codeunit "MFG Cost Drift Engine";
        DemoCostDrift: Codeunit "MFG Demo Cost Drift";
    begin
        EnsureSetup(Setup);
        Engine.EnsureSources();

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoCostDrift.Import();
    end;

    /// <summary>
    /// Creates or refreshes the standard cost drift MCP configurations: the functional one and the one that only
    /// seeds sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single standard cost drift setup record exists, with a 2 % tolerance and a 30-day variance
    /// period when it is first created.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG Cost Drift Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Tolerance %" := 2;
        Setup."Variance Days" := 30;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Cost Drift Line");
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Drift Source", false, true, false);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Order Variance", false, false, false);
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo Cost Drift");
        MCPSetup.Activate(ConfigId);
    end;
}
