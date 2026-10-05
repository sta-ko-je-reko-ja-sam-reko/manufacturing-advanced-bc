namespace ManufacturingAdvanced.PlanningInsight;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Tracking;

codeunit 85502 "MFG Planning Engine"
{
    Access = Public;

    var
        CountKeyTok: Label '%1|%2', Locked = true;

    /// <summary>
    /// Records the action messages of a planning worksheet batch as one planning run. A batch without action
    /// messages records nothing.
    /// </summary>
    /// <param name="TemplateName">The worksheet template.</param>
    /// <param name="BatchName">The worksheet batch.</param>
    /// <returns>The number of the run, or zero when nothing was recorded.</returns>
    procedure RecordRun(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        RequisitionLine: Record "Requisition Line";
        PlanningRun: Record "MFG Planning Run";
        PlanningMessage: Record "MFG Planning Message";
        EntryNo: Integer;
    begin
        RequisitionLine.SetRange("Worksheet Template Name", TemplateName);
        RequisitionLine.SetRange("Journal Batch Name", BatchName);
        RequisitionLine.SetRange(Type, RequisitionLine.Type::Item);
        RequisitionLine.SetFilter("Action Message", '<>%1', RequisitionLine."Action Message"::" ");
        if not RequisitionLine.FindSet() then
            exit(0);

        PlanningRun.Init();
        PlanningRun."Worksheet Template Name" := TemplateName;
        PlanningRun."Journal Batch Name" := BatchName;
        PlanningRun."Recorded At" := CurrentDateTime();
        PlanningRun."Recorded By" := CopyStr(UserId(), 1, MaxStrLen(PlanningRun."Recorded By"));
        PlanningRun.Insert(true);

        repeat
            EntryNo += 1;
            PlanningMessage.Init();
            PlanningMessage."Run No." := PlanningRun."Run No.";
            PlanningMessage."Entry No." := EntryNo;
            PlanningMessage."Item No." := RequisitionLine."No.";
            PlanningMessage."Variant Code" := RequisitionLine."Variant Code";
            PlanningMessage."Location Code" := RequisitionLine."Location Code";
            PlanningMessage."Action Message" := RequisitionLine."Action Message";
            PlanningMessage."Original Due Date" := RequisitionLine."Original Due Date";
            PlanningMessage."Due Date" := RequisitionLine."Due Date";
            PlanningMessage."Original Quantity" := RequisitionLine."Original Quantity";
            PlanningMessage.Quantity := RequisitionLine.Quantity;
            PlanningMessage."Ref. Order Type" := RequisitionLine."Ref. Order Type";
            PlanningMessage."Ref. Order No." := RequisitionLine."Ref. Order No.";
            PlanningMessage.Insert(true);
        until RequisitionLine.Next() = 0;

        exit(PlanningRun."Run No.");
    end;

    /// <summary>
    /// Rebuilds the item insights from the planning runs recorded within the history period: per item, in how
    /// many runs it got each kind of action message, its planning parameters, and the advice of the first
    /// active rule whose pattern is there.
    /// </summary>
    /// <returns>The number of items with at least one action message.</returns>
    procedure Analyze(): Integer
    var
        Setup: Record "MFG Planning Setup";
        PlanningRun: Record "MFG Planning Run";
        Insight: Record "MFG Item Planning Insight";
        TempInsight: Record "MFG Item Planning Insight" temporary;
        LastCountedRun: Dictionary of [Text, Integer];
        AnalyzedAt: DateTime;
    begin
        EnsureRules();
        if not Setup.Get() then
            Clear(Setup);
        if Setup."History Days" <= 0 then
            Setup."History Days" := 90;
        if Setup."Churn Threshold" <= 0 then
            Setup."Churn Threshold" := 3;

        PlanningRun.SetFilter("Recorded At", '>=%1', CreateDateTime(Today() - Setup."History Days", 0T));
        if PlanningRun.FindSet() then
            repeat
                CountRun(PlanningRun."Run No.", TempInsight, LastCountedRun);
            until PlanningRun.Next() = 0;

        Insight.DeleteAll();
        AnalyzedAt := CurrentDateTime();
        TempInsight.Reset();
        if TempInsight.FindSet() then
            repeat
                Insight := TempInsight;
                FillItemParameters(Insight);
                Advise(Insight, Setup."Churn Threshold");
                Insight."Analyzed At" := AnalyzedAt;
                Insight.Insert(true);
            until TempInsight.Next() = 0;
        exit(Insight.Count());
    end;

    /// <summary>
    /// Creates a configuration row, active and with the advisor's own description, for every advisor that does
    /// not have one yet. Rows that exist keep the choice the user made.
    /// </summary>
    procedure EnsureRules()
    var
        PlanningRule: Record "MFG Planning Rule";
        PlanningAdvisor: Interface "MFG IPlanningAdvisor";
        AdvisorType: Enum "MFG Planning Advisor Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Planning Advisor Type".Ordinals() do begin
            AdvisorType := Enum::"MFG Planning Advisor Type".FromInteger(Ordinal);
            if (AdvisorType <> AdvisorType::MFGNone) and not PlanningRule.Get(AdvisorType) then begin
                PlanningAdvisor := AdvisorType;
                PlanningRule.Init();
                PlanningRule.Advisor := AdvisorType;
                PlanningRule.Active := true;
                PlanningRule.Description := CopyStr(PlanningAdvisor.Description(), 1, MaxStrLen(PlanningRule.Description));
                PlanningRule.Insert(true);
            end;
        end;
    end;

    local procedure CountRun(RunNo: Integer; var TempInsight: Record "MFG Item Planning Insight" temporary; var LastCountedRun: Dictionary of [Text, Integer])
    var
        PlanningMessage: Record "MFG Planning Message";
    begin
        PlanningMessage.SetRange("Run No.", RunNo);
        if not PlanningMessage.FindSet() then
            exit;

        repeat
            if not TempInsight.Get(PlanningMessage."Item No.") then begin
                TempInsight.Init();
                TempInsight."Item No." := PlanningMessage."Item No.";
                TempInsight.Insert();
            end;

            if FirstInRun(LastCountedRun, PlanningMessage."Item No.", 'ANY', RunNo) then
                TempInsight."Runs With Messages" += 1;
            case PlanningMessage."Action Message" of
                PlanningMessage."Action Message"::New:
                    if FirstInRun(LastCountedRun, PlanningMessage."Item No.", 'NEW', RunNo) then
                        TempInsight."New Runs" += 1;
                PlanningMessage."Action Message"::"Change Qty.":
                    if FirstInRun(LastCountedRun, PlanningMessage."Item No.", 'QTY', RunNo) then
                        TempInsight."Change Qty. Runs" += 1;
                PlanningMessage."Action Message"::Reschedule, PlanningMessage."Action Message"::"Resched. & Chg. Qty.":
                    if FirstInRun(LastCountedRun, PlanningMessage."Item No.", 'RESCHED', RunNo) then
                        TempInsight."Reschedule Runs" += 1;
                PlanningMessage."Action Message"::Cancel:
                    if FirstInRun(LastCountedRun, PlanningMessage."Item No.", 'CANCEL', RunNo) then
                        TempInsight."Cancel Runs" += 1;
            end;
            TempInsight.Modify();
        until PlanningMessage.Next() = 0;
    end;

    local procedure FirstInRun(var LastCountedRun: Dictionary of [Text, Integer]; ItemNo: Code[20]; Category: Text; RunNo: Integer): Boolean
    var
        CountKey: Text;
        LastRun: Integer;
    begin
        CountKey := StrSubstNo(CountKeyTok, ItemNo, Category);
        if LastCountedRun.Get(CountKey, LastRun) then
            if LastRun = RunNo then
                exit(false);
        LastCountedRun.Set(CountKey, RunNo);
        exit(true);
    end;

    local procedure FillItemParameters(var Insight: Record "MFG Item Planning Insight")
    var
        Item: Record Item;
    begin
        Item.SetLoadFields(Description, "Reordering Policy", "Dampener Period", "Dampener Quantity", "Lot Accumulation Period", "Rescheduling Period");
        if not Item.Get(Insight."Item No.") then
            exit;

        Insight.Description := Item.Description;
        Insight."Reordering Policy" := Item."Reordering Policy";
        Insight."Dampener Period" := CopyStr(Format(Item."Dampener Period"), 1, MaxStrLen(Insight."Dampener Period"));
        Insight."Dampener Quantity" := Item."Dampener Quantity";
        Insight."Lot Accumulation Period" := CopyStr(Format(Item."Lot Accumulation Period"), 1, MaxStrLen(Insight."Lot Accumulation Period"));
        Insight."Rescheduling Period" := CopyStr(Format(Item."Rescheduling Period"), 1, MaxStrLen(Insight."Rescheduling Period"));
    end;

    local procedure Advise(var Insight: Record "MFG Item Planning Insight"; Threshold: Integer)
    var
        PlanningRule: Record "MFG Planning Rule";
        PlanningAdvisor: Interface "MFG IPlanningAdvisor";
        AdvisorType: Enum "MFG Planning Advisor Type";
        Advice: Text;
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Planning Advisor Type".Ordinals() do begin
            AdvisorType := Enum::"MFG Planning Advisor Type".FromInteger(Ordinal);
            if PlanningRule.Get(AdvisorType) then
                if PlanningRule.Active then begin
                    PlanningAdvisor := AdvisorType;
                    if PlanningAdvisor.Evaluate(Insight, Threshold, Advice) then begin
                        Insight.Advisor := AdvisorType;
                        Insight.Advice := CopyStr(Advice, 1, MaxStrLen(Insight.Advice));
                        exit;
                    end;
                end;
        end;
    end;
}
