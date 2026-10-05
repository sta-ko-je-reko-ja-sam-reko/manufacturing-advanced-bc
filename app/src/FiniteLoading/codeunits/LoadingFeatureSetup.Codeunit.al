namespace ManufacturingAdvanced.FiniteLoading;

using ManufacturingAdvanced.Core;

codeunit 85700 "MFG Loading Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Finite loading';
        StepDescriptionLbl: Label 'See when a work center can really do its open operations: sequenced by a strategy you choose and loaded day by day onto its calendar capacity, with the operations that will finish late.';
        McpConfigNameTok: Label 'Manufacturing Advanced - Finite Loading', Locked = true;
        McpConfigDescLbl: Label 'Finite loading tools. Read the Manufacturing Advanced Finite Loading agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Finite Loading', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds finite loading sample data. Read the Manufacturing Advanced Demo Finite Loading agent instructions before use.';

    /// <summary>
    /// Adds the finite loading step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 90;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGFiniteLoading;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG Loading Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the finite loading setup record.
    /// </summary>
    /// <returns>True when finite loading is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG Loading Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for finite loading. The feature numbers nothing, so the number series
    /// choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether finite loading should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG Loading Setup";
        DemoLoading: Codeunit "MFG Demo Loading";
    begin
        EnsureSetup(Setup);

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoLoading.Import();
    end;

    /// <summary>
    /// Creates or refreshes the finite loading MCP configurations: the functional one and the one that only seeds
    /// sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single finite loading setup record exists, with a 30-day horizon, sequencing by due date.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG Loading Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Horizon Days" := 30;
        Setup.Sequencing := Setup.Sequencing::MFGDueDate;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Load Plan Line", false, false, false);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Loading Work Center");
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo Loading");
        MCPSetup.Activate(ConfigId);
    end;
}
