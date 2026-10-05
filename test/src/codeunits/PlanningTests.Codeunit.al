namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.PlanningInsight;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Tracking;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89011 "MFG Planning Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure RecordingABatchStoresItsActionMessages()
    var
        PlanningMessage: Record "MFG Planning Message";
        Engine: Codeunit "MFG Planning Engine";
        RunNo: Integer;
    begin
        // [GIVEN] A planning batch with two action messages and one line without
        ClearBatch();
        AddLine(10000, 'MFGP-A', "Action Message Type"::Reschedule);
        AddLine(20000, 'MFGP-A', "Action Message Type"::"Change Qty.");
        AddLine(30000, 'MFGP-B', "Action Message Type"::" ");

        // [WHEN] The batch is recorded
        RunNo := Engine.RecordRun(TemplateName(), BatchName());

        // [THEN] One run with the two messages
        Assert.AreNotEqual(0, RunNo, 'A run should be recorded.');
        PlanningMessage.SetRange("Run No.", RunNo);
        Assert.RecordCount(PlanningMessage, 2);
    end;

    [Test]
    procedure ABatchWithoutMessagesRecordsNothing()
    var
        Engine: Codeunit "MFG Planning Engine";
    begin
        // [GIVEN] A planning batch whose only line has no action message
        ClearBatch();
        AddLine(10000, 'MFGP-A', "Action Message Type"::" ");

        // [WHEN] The batch is recorded
        // [THEN] Nothing is recorded
        Assert.AreEqual(0, Engine.RecordRun(TemplateName(), BatchName()), 'No run without messages.');
    end;

    [Test]
    procedure AnalysisCountsRunsNotMessages()
    var
        Insight: Record "MFG Item Planning Insight";
        Engine: Codeunit "MFG Planning Engine";
        RunIndex: Integer;
    begin
        // [GIVEN] Three runs in which item MFGP-C was rescheduled, twice in the first run
        PrepareSetup(3);
        for RunIndex := 1 to 3 do begin
            ClearBatch();
            AddLine(10000, 'MFGP-C', "Action Message Type"::Reschedule);
            if RunIndex = 1 then
                AddLine(20000, 'MFGP-C', "Action Message Type"::"Resched. & Chg. Qty.");
            Engine.RecordRun(TemplateName(), BatchName());
        end;

        // [WHEN] The history is analysed
        Engine.Analyze();

        // [THEN] Three runs with a reschedule, not four messages
        Insight.Get('MFGP-C');
        Assert.AreEqual(3, Insight."Runs With Messages", 'Runs are counted once per item.');
        Assert.AreEqual(3, Insight."Reschedule Runs", 'Two reschedules in one run count as one run.');
    end;

    [Test]
    procedure RepeatedReschedulesAdviseADampenerPeriod()
    var
        Insight: Record "MFG Item Planning Insight";
        Engine: Codeunit "MFG Planning Engine";
        RunIndex: Integer;
    begin
        // [GIVEN] An item without a dampener period, rescheduled in three runs, and a threshold of three
        PrepareSetup(3);
        CreateItem('MFGP-D');
        for RunIndex := 1 to 3 do begin
            ClearBatch();
            AddLine(10000, 'MFGP-D', "Action Message Type"::Reschedule);
            Engine.RecordRun(TemplateName(), BatchName());
        end;

        // [WHEN] The history is analysed
        Engine.Analyze();

        // [THEN] The rescheduling pattern advises a dampener period
        Insight.Get('MFGP-D');
        Assert.AreEqual(Insight.Advisor::MFGReschedules, Insight.Advisor, 'The rescheduling pattern applies.');
        Assert.IsTrue(StrPos(Insight.Advice, 'Dampener Period') > 0, 'The advice names the parameter.');
    end;

    [Test]
    procedure BelowTheThresholdThereIsNoAdvice()
    var
        Insight: Record "MFG Item Planning Insight";
        Engine: Codeunit "MFG Planning Engine";
        RunIndex: Integer;
    begin
        // [GIVEN] An item rescheduled in two runs, and a threshold of three
        PrepareSetup(3);
        for RunIndex := 1 to 2 do begin
            ClearBatch();
            AddLine(10000, 'MFGP-E', "Action Message Type"::Reschedule);
            Engine.RecordRun(TemplateName(), BatchName());
        end;

        // [WHEN] The history is analysed
        Engine.Analyze();

        // [THEN] The item is listed without advice
        Insight.Get('MFGP-E');
        Assert.AreEqual('', Insight.Advice, 'Two runs are not yet a pattern.');
    end;

    [Test]
    procedure CancelAndNewAdviseLongerPeriods()
    var
        Insight: Record "MFG Item Planning Insight";
        Engine: Codeunit "MFG Planning Engine";
        RunIndex: Integer;
    begin
        // [GIVEN] An item cancelled and re-created in three runs
        PrepareSetup(3);
        for RunIndex := 1 to 3 do begin
            ClearBatch();
            AddLine(10000, 'MFGP-F', "Action Message Type"::Cancel);
            AddLine(20000, 'MFGP-F', "Action Message Type"::New);
            Engine.RecordRun(TemplateName(), BatchName());
        end;

        // [WHEN] The history is analysed
        Engine.Analyze();

        // [THEN] The cancel-and-new pattern applies
        Insight.Get('MFGP-F');
        Assert.AreEqual(Insight.Advisor::MFGCancelAndNew, Insight.Advisor, 'The cancel-and-new pattern applies.');
    end;

    [Test]
    procedure AnInactiveRuleGivesNoAdvice()
    var
        Insight: Record "MFG Item Planning Insight";
        PlanningRule: Record "MFG Planning Rule";
        Engine: Codeunit "MFG Planning Engine";
        RunIndex: Integer;
    begin
        // [GIVEN] The rescheduling rule is inactive, and an item rescheduled in three runs
        PrepareSetup(3);
        PlanningRule.Get(PlanningRule.Advisor::MFGReschedules);
        PlanningRule.Active := false;
        PlanningRule.Modify(true);
        for RunIndex := 1 to 3 do begin
            ClearBatch();
            AddLine(10000, 'MFGP-G', "Action Message Type"::Reschedule);
            Engine.RecordRun(TemplateName(), BatchName());
        end;

        // [WHEN] The history is analysed
        Engine.Analyze();

        // [THEN] No advice
        Insight.Get('MFGP-G');
        Assert.AreEqual('', Insight.Advice, 'An inactive rule gives no advice.');
        PlanningRule.Active := true;
        PlanningRule.Modify(true);
    end;

    [Test]
    procedure TheReactionsRecordOnlyWhileTheFeatureIsOn()
    var
        PlanningRun: Record "MFG Planning Run";
        Reactions: Codeunit "MFG Planning Reactions";
        Before: Integer;
    begin
        // [GIVEN] A batch with a message
        ClearBatch();
        AddLine(10000, 'MFGP-H', "Action Message Type"::New);
        Before := PlanningRun.Count();

        // [WHEN] Planning finishes while the feature is off, then while it is on
        SetFeature(false);
        Reactions.OnAfterCalculatePlan(TemplateName(), BatchName());
        Assert.AreEqual(Before, PlanningRun.Count(), 'Nothing is recorded while the feature is off.');
        SetFeature(true);
        Reactions.OnAfterCalculatePlan(TemplateName(), BatchName());

        // [THEN] One run is recorded
        Assert.AreEqual(Before + 1, PlanningRun.Count(), 'One run is recorded while the feature is on.');
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG Planning Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] Step 60, with a toggle, opening the feature setup page
        TempSetupStep.FindFirst();
        Assert.AreEqual(60, TempSetupStep."Step No.", 'Planning insight comes after standard cost drift.');
        Assert.AreEqual(Page::"MFG Planning Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure ImportingSampleDataBuildsThePackage()
    var
        PlanningRule: Record "MFG Planning Rule";
        ConfigPackage: Record "Config. Package";
        DemoPlanning: Codeunit "MFG Demo Planning";
    begin
        // [WHEN] The sample data is imported twice
        DemoPlanning.Import();
        DemoPlanning.Import();

        // [THEN] The rules and the configuration package exist once
        Assert.RecordCount(PlanningRule, 3);
        Assert.IsTrue(ConfigPackage.Get('MFG-PLANNING'), 'Importing sample data should build the configuration package.');
    end;

    local procedure TemplateName(): Code[10]
    begin
        exit('MFGP-TMPL');
    end;

    local procedure BatchName(): Code[10]
    begin
        exit('MFGP-BATCH');
    end;

    local procedure ClearBatch()
    var
        RequisitionLine: Record "Requisition Line";
    begin
        RequisitionLine.SetRange("Worksheet Template Name", TemplateName());
        RequisitionLine.SetRange("Journal Batch Name", BatchName());
        RequisitionLine.DeleteAll(false);
    end;

    local procedure AddLine(LineNo: Integer; ItemNo: Code[20]; ActionMessage: Enum "Action Message Type")
    var
        RequisitionLine: Record "Requisition Line";
    begin
        RequisitionLine.Init();
        RequisitionLine."Worksheet Template Name" := TemplateName();
        RequisitionLine."Journal Batch Name" := BatchName();
        RequisitionLine."Line No." := LineNo;
        RequisitionLine.Type := RequisitionLine.Type::Item;
        RequisitionLine."No." := ItemNo;
        RequisitionLine."Action Message" := ActionMessage;
        RequisitionLine.Quantity := 1;
        RequisitionLine."Due Date" := WorkDate();
        RequisitionLine.Insert(false);
    end;

    local procedure CreateItem(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit;
        Item.Init();
        Item."No." := ItemNo;
        Item.Insert(false);
    end;

    local procedure PrepareSetup(Threshold: Integer)
    var
        Setup: Record "MFG Planning Setup";
        PlanningRun: Record "MFG Planning Run";
        PlanningMessage: Record "MFG Planning Message";
        FeatureSetup: Codeunit "MFG Planning Feature Setup";
        Engine: Codeunit "MFG Planning Engine";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."Churn Threshold" := Threshold;
        Setup."History Days" := 90;
        Setup.Modify(true);
        Engine.EnsureRules();
        PlanningMessage.DeleteAll();
        PlanningRun.DeleteAll();
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Planning Setup";
        FeatureSetup: Codeunit "MFG Planning Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Record After Planning" := true;
        Setup.Modify(true);
    end;
}
