namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;

codeunit 85500 "MFG Planning Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Planning insight';
        StepDescriptionLbl: Label 'Record the action messages of every planning run, find the items planning keeps rescheduling, changing or cancelling, and see which planning parameter to adjust.';
        McpConfigNameTok: Label 'Manufacturing Advanced - Planning Insight', Locked = true;
        McpConfigDescLbl: Label 'Planning insight tools. Read the Manufacturing Advanced Planning Insight agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Planning Insight', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds planning insight sample data. Read the Manufacturing Advanced Demo Planning Insight agent instructions before use.';

    /// <summary>
    /// Adds the planning insight step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 60;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGPlanningInsight;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG Planning Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the planning insight setup record.
    /// </summary>
    /// <returns>True when planning insight is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG Planning Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for planning insight. The feature numbers nothing, so the number series
    /// choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether planning insight should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG Planning Setup";
        Engine: Codeunit "MFG Planning Engine";
        DemoPlanning: Codeunit "MFG Demo Planning";
    begin
        EnsureSetup(Setup);
        Engine.EnsureRules();

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoPlanning.Import();
    end;

    /// <summary>
    /// Creates or refreshes the planning insight MCP configurations: the functional one and the one that only
    /// seeds sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single planning insight setup record exists, recording after every Calculate Plan, with a
    /// threshold of three runs and 90 days of history.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG Planning Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Record After Planning" := true;
        Setup."Churn Threshold" := 3;
        Setup."History Days" := 90;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Planning Insight", false, false, false);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Planning Message", false, false, false);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Planning Rule", false, true, false);
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo Planning");
        MCPSetup.Activate(ConfigId);
    end;
}
