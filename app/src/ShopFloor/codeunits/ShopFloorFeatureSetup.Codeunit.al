namespace ManufacturingAdvanced.ShopFloor;

using ManufacturingAdvanced.Core;

codeunit 85600 "MFG Shop Floor Feature Setup" implements "MFG IFeatureSetup"
{
    Access = Public;

    var
        StepNameLbl: Label 'Shop floor terminal';
        StepDescriptionLbl: Label 'Let operators start and stop operations, report output and scrap, and report downtime on a touch-friendly page, posted straight through the standard output journal posting.';
        McpConfigNameTok: Label 'Manufacturing Advanced - Shop Floor Terminal', Locked = true;
        McpConfigDescLbl: Label 'Shop floor tools. Read the Manufacturing Advanced Shop Floor Terminal agent instructions before use.';
        DemoMcpConfigNameTok: Label 'Manufacturing Advanced - Demo Shop Floor Terminal', Locked = true;
        DemoMcpConfigDescLbl: Label 'Seeds shop floor terminal sample data. Read the Manufacturing Advanced Demo Shop Floor Terminal agent instructions before use.';

    /// <summary>
    /// Adds the shop floor terminal step to the guided setup list.
    /// </summary>
    /// <param name="TempSetupStep">The guided setup step buffer to add a row to.</param>
    procedure RegisterStep(var TempSetupStep: Record "MFG Setup Step" temporary)
    begin
        TempSetupStep.Init();
        TempSetupStep."Step No." := 70;
        TempSetupStep.Feature := TempSetupStep.Feature::MFGShopFloor;
        TempSetupStep."Has Toggle" := true;
        TempSetupStep."Has No. Series" := false;
        TempSetupStep.Name := CopyStr(StepNameLbl, 1, MaxStrLen(TempSetupStep.Name));
        TempSetupStep.Description := CopyStr(StepDescriptionLbl, 1, MaxStrLen(TempSetupStep.Description));
        TempSetupStep."Setup Page ID" := Page::"MFG Shop Floor Setup";
        TempSetupStep.Insert(true);
    end;

    /// <summary>
    /// Reads the enabled flag from the shop floor setup record.
    /// </summary>
    /// <returns>True when the shop floor terminal is switched on.</returns>
    procedure IsEnabled(): Boolean
    var
        Setup: Record "MFG Shop Floor Setup";
    begin
        Setup.SetLoadFields("MFG Enabled");
        if not Setup.Get() then
            exit(false);
        exit(Setup."MFG Enabled");
    end;

    /// <summary>
    /// Applies the guided setup choices for the shop floor terminal. The feature numbers nothing, so the number
    /// series choice is ignored. Never restarts the session; the setup hub owns the single restart.
    /// </summary>
    /// <param name="Enable">Whether the shop floor terminal should be switched on.</param>
    /// <param name="CreateNoSeries">Ignored.</param>
    /// <param name="ImportDemoData">Whether to load the sample data and build the configuration package.</param>
    procedure ApplyChoices(Enable: Boolean; CreateNoSeries: Boolean; ImportDemoData: Boolean)
    var
        Setup: Record "MFG Shop Floor Setup";
        DemoShopFloor: Codeunit "MFG Demo Shop Floor";
    begin
        EnsureSetup(Setup);

        Setup.Validate("MFG Enabled", Enable);
        Setup.Modify(true);

        if ImportDemoData then
            DemoShopFloor.Import();
    end;

    /// <summary>
    /// Creates or refreshes the shop floor MCP configurations: the functional one and the one that only seeds
    /// sample data.
    /// </summary>
    procedure RegisterMcpConfiguration()
    begin
        RegisterFunctionalConfiguration();
        RegisterDemoConfiguration();
    end;

    /// <summary>
    /// Ensures the single shop floor setup record exists, posting clocked run time.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureSetup(var Setup: Record "MFG Shop Floor Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup."Post Run Time" := true;
        Setup.Insert(true);
    end;

    local procedure RegisterFunctionalConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(McpConfigNameTok, McpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Shop Floor Operation");
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Shop Floor Event", false, false, false);
        MCPSetup.EnsureApiTool(ConfigId, Page::"MFG API Shop Floor Session", false, false, false);
        MCPSetup.Activate(ConfigId);
    end;

    local procedure RegisterDemoConfiguration()
    var
        MCPSetup: Codeunit "MFG MCP Setup";
        ConfigId: Guid;
    begin
        ConfigId := MCPSetup.EnsureConfiguration(DemoMcpConfigNameTok, DemoMcpConfigDescLbl);
        MCPSetup.EnsureActionTool(ConfigId, Page::"MFG API Demo Shop Floor");
        MCPSetup.Activate(ConfigId);
    end;
}
