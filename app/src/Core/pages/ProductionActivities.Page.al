namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.CostDrift;
using ManufacturingAdvanced.EngineeringChange;
using ManufacturingAdvanced.FiniteLoading;
using ManufacturingAdvanced.PlanningInsight;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.ShopFloor;
using ManufacturingAdvanced.WIPControl;

page 85003 "MFG Production Activities"
{
    PageType = CardPart;
    Caption = 'Production activities';
    SourceTable = "MFG Activities Cue";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(Release)
            {
                Caption = 'Release and refresh';

                field("Preflight Errors"; Rec."Preflight Errors")
                {
                    ApplicationArea = MFGPreflight;

                    trigger OnDrillDown()
                    var
                        PreflightFinding: Record "MFG Preflight Finding";
                    begin
                        PreflightFinding.SetRange(Severity, PreflightFinding.Severity::MFGError);
                        Page.Run(Page::"MFG Preflight Findings", PreflightFinding);
                    end;
                }
                field("Changes to Restore"; Rec."Changes to Restore")
                {
                    ApplicationArea = MFGRefreshGuard;

                    trigger OnDrillDown()
                    var
                        RefreshChange: Record "MFG Refresh Change";
                    begin
                        RefreshChange.SetRange(Restorable, true);
                        RefreshChange.SetRange(Restored, false);
                        Page.Run(Page::"MFG Refresh Changes", RefreshChange);
                    end;
                }
            }
            cuegroup(Shop)
            {
                Caption = 'Shop floor and capacity';

                field("Operations Running"; Rec."Operations Running")
                {
                    ApplicationArea = MFGShopFloor;
                    DrillDownPageId = "MFG Shop Floor Sessions";
                }
                field("Late Operations"; Rec."Late Operations")
                {
                    ApplicationArea = MFGFiniteLoading;
                    DrillDownPageId = "MFG Load Plan";
                }
            }
            cuegroup(Finish)
            {
                Caption = 'Finishing and cost';

                field("Orders Ready to Finish"; Rec."Orders Ready to Finish")
                {
                    ApplicationArea = MFGWIPControl;
                    DrillDownPageId = "MFG Finish Proposals";
                }
                field("WIP to Investigate"; Rec."WIP to Investigate")
                {
                    ApplicationArea = MFGWIPControl;

                    trigger OnDrillDown()
                    var
                        WipReconciliation: Record "MFG WIP Reconciliation";
                    begin
                        WipReconciliation.SetRange(Status, WipReconciliation.Status::MFGInvestigate);
                        Page.Run(Page::"MFG WIP Reconciliation", WipReconciliation);
                    end;
                }
                field("Cost Drift Lines"; Rec."Cost Drift Lines")
                {
                    ApplicationArea = MFGCostDrift;
                    DrillDownPageId = "MFG Cost Drift";
                }
            }
            cuegroup(Engineering)
            {
                Caption = 'Engineering and planning';

                field("ECOs Pending Approval"; Rec."ECOs Pending Approval")
                {
                    ApplicationArea = MFGEngineeringChange;

                    trigger OnDrillDown()
                    var
                        EcoHeader: Record "MFG ECO Header";
                    begin
                        EcoHeader.SetRange(Status, EcoHeader.Status::MFGPendingApproval);
                        Page.Run(Page::"MFG ECO List", EcoHeader);
                    end;
                }
                field("ECOs to Implement"; Rec."ECOs to Implement")
                {
                    ApplicationArea = MFGEngineeringChange;

                    trigger OnDrillDown()
                    var
                        EcoHeader: Record "MFG ECO Header";
                    begin
                        EcoHeader.SetRange(Status, EcoHeader.Status::MFGApproved);
                        Page.Run(Page::"MFG ECO List", EcoHeader);
                    end;
                }
                field("Items with Planning Advice"; Rec."Items with Planning Advice")
                {
                    ApplicationArea = MFGPlanningInsight;

                    trigger OnDrillDown()
                    var
                        ItemPlanningInsight: Record "MFG Item Planning Insight";
                    begin
                        ItemPlanningInsight.SetFilter(Advisor, '<>%1', ItemPlanningInsight.Advisor::MFGNone);
                        Page.Run(Page::"MFG Item Planning Insights", ItemPlanningInsight);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        TaskParameters: Dictionary of [Text, Text];
    begin
        Rec.InitCue();
        CurrPage.EnqueueBackgroundTask(CueTaskId, Codeunit::"MFG Activities Cue Calc", TaskParameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> CueTaskId then
            exit;
        SetCue(Rec."Preflight Errors", Results, Rec.FieldNo("Preflight Errors"));
        SetCue(Rec."Orders Ready to Finish", Results, Rec.FieldNo("Orders Ready to Finish"));
        SetCue(Rec."WIP to Investigate", Results, Rec.FieldNo("WIP to Investigate"));
        SetCue(Rec."Changes to Restore", Results, Rec.FieldNo("Changes to Restore"));
        SetCue(Rec."Cost Drift Lines", Results, Rec.FieldNo("Cost Drift Lines"));
        SetCue(Rec."Items with Planning Advice", Results, Rec.FieldNo("Items with Planning Advice"));
        SetCue(Rec."Operations Running", Results, Rec.FieldNo("Operations Running"));
        SetCue(Rec."ECOs Pending Approval", Results, Rec.FieldNo("ECOs Pending Approval"));
        SetCue(Rec."ECOs to Implement", Results, Rec.FieldNo("ECOs to Implement"));
        SetCue(Rec."Late Operations", Results, Rec.FieldNo("Late Operations"));
        Rec.Modify();
        CurrPage.Update(false);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    var
        CueTaskId: Integer;

    local procedure SetCue(var Target: Integer; Results: Dictionary of [Text, Text]; CueFieldNo: Integer)
    var
        Value: Integer;
    begin
        if Results.ContainsKey(Format(CueFieldNo)) then
            if Evaluate(Value, Results.Get(Format(CueFieldNo))) then
                Target := Value;
    end;
}
