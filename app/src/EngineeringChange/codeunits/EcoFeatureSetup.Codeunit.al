namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;

codeunit 85800 "MFG ECO Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Engineering change';
        StepDescriptionLbl: Label 'Change production BOMs and routings through an engineering change order: new versions under development, approval, certification on an effective date, and the open production orders affected.';
        NoSeriesCodeTok: Label 'MFG-ECO', Locked = true;
        NoSeriesDescLbl: Label 'Engineering change orders';
        StartingNoTok: Label 'ECO00001', Locked = true;
        EndingNoTok: Label 'ECO99999', Locked = true;
        McpConfigNameTok: Label 'Manufacturing Advanced - Engineering Change', Locked = true;
        McpConfigDescLbl: Label 'Engineering change tools. Read the Manufacturing Advanced Engineering Change agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Engineering Change', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds engineering change sample data. Read the Manufacturing Advanced Demo Engineering Change agent instructions before use.';

    /// <summary>
    /// Adds the engineering change step to the guided setup list. The feature numbers its orders, so the wizard
    /// offers to create the number series.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 80;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGEngineeringChange;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := true;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG ECO Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the engineering change setup record.
    /// </summary>
    /// <returns>True when engineering change orders are switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG ECO Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for engineering change orders. Never restarts the session; the setup hub
    /// owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether engineering change orders should be switched on.</param>
    /// <param name="CreateNoSeries">Whether to create the number series MFG-ECO and assign it.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG ECO Setup";
        DemoEco: Codeunit "MFG Demo ECO";
    begin
        EnsureSetup(Setup);

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if CreateNoSeries then
            EnsureNoSeries(Setup);

        if ImportDemoData then
            DemoEco.Import();
    end;

    /// <summary>
    /// Creates or refreshes the engineering change MCP configurations: the functional one and the one that only
    /// seeds sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single engineering change setup record exists, with a separate approver required.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG ECO Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Separate Approver" := true;
        Setup.Insert(true);
    end;

    /// <summary>
    /// Creates number series MFG-ECO and assigns it, when the setup has no series yet.
    /// </summary>
    /// <param name="Setup">The setup record.</param>
    procedure EnsureNoSeries(var Setup: Record "MFG ECO Setup")
    var
        NoSeriesMgt: Codeunit "MFG No. Series Mgt.";
    begin
        if Setup."ECO Nos." <> '' then
            exit;

        Setup.Validate("ECO Nos.", NoSeriesMgt.EnsureSeries(NoSeriesCodeTok, NoSeriesDescLbl, StartingNoTok, EndingNoTok));
        Setup.Modify(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API ECO", true, true, false);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API ECO");
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API ECO Line", true, true, true);
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo ECO");
        MCPSetup.Activate(ConfigId);
    end;
}
