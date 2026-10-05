namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;
using Microsoft.Inventory.Requisition;

codeunit 85506 "MFG Demo Planning"
{
    Access = Public;

    var
        PackageCodeTok: Label 'MFG-PLANNING', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Planning Insight';

    /// <summary>
    /// Seeds the planning insight sample data. Creates the rule configuration, records the action messages
    /// already on every planning worksheet batch of the company as one run per batch (once per batch and day),
    /// analyses them, and builds the feature's configuration package. It does not run the planning.
    /// </summary>
    procedure Import()
    var
        Engine: Codeunit "MFG Planning Engine";
    begin
        Engine.EnsureRules();
        RecordCurrentBatches();
        Engine.Analyze();
        CreateConfigPackage();
    end;

    local procedure RecordCurrentBatches()
    var
        RequisitionWkshName: Record "Requisition Wksh. Name";
        Engine: Codeunit "MFG Planning Engine";
    begin
        RequisitionWkshName.SetRange("Template Type", RequisitionWkshName."Template Type"::Planning);
        if not RequisitionWkshName.FindSet() then
            exit;

        repeat
            if not RecordedToday(RequisitionWkshName) then
                Engine.RecordRun(RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name);
        until RequisitionWkshName.Next() = 0;
    end;

    local procedure RecordedToday(RequisitionWkshName: Record "Requisition Wksh. Name"): Boolean
    var
        PlanningRun: Record "MFG Planning Run";
    begin
        PlanningRun.SetRange("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
        PlanningRun.SetRange("Journal Batch Name", RequisitionWkshName.Name);
        PlanningRun.SetFilter("Recorded At", '>=%1', CreateDateTime(Today(), 0T));
        exit(not PlanningRun.IsEmpty());
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Planning Rule");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Planning Run");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Planning Message");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Item Planning Insight");
    end;
}
