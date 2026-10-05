namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.CostDrift;
using ManufacturingAdvanced.EngineeringChange;
using ManufacturingAdvanced.FiniteLoading;
using ManufacturingAdvanced.PlanningInsight;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.ShopFloor;
using ManufacturingAdvanced.WIPControl;

codeunit 85009 "MFG Activities Cue Calc"
{
    Access = Public;

    /// <summary>
    /// Runs as a page background task of the production activities: counts every cue and hands the counts back.
    /// </summary>
    trigger OnRun()
    var
        Results: Dictionary of [Text, Text];
    begin
        CollectCounts(Results);
        Page.SetBackgroundTaskResult(Results);
    end;

    /// <summary>
    /// Counts every cue of the production activities, keyed by the cue's field number. Read only.
    /// </summary>
    /// <param name="Results">Receives one count per cue field.</param>
    procedure CollectCounts(var Results: Dictionary of [Text, Text])
    var
        TempCue: Record "MFG Activities Cue";
        PreflightFinding: Record "MFG Preflight Finding";
        FinishProposal: Record "MFG Finish Proposal";
        WipReconciliation: Record "MFG WIP Reconciliation";
        RefreshChange: Record "MFG Refresh Change";
        CostDriftLine: Record "MFG Cost Drift Line";
        ItemPlanningInsight: Record "MFG Item Planning Insight";
        ShopFloorSession: Record "MFG Shop Floor Session";
        EcoHeader: Record "MFG ECO Header";
        LoadPlanLine: Record "MFG Load Plan Line";
    begin
        PreflightFinding.SetRange(Severity, PreflightFinding.Severity::MFGError);
        Results.Set(Format(TempCue.FieldNo("Preflight Errors")), Format(PreflightFinding.Count()));

        FinishProposal.SetRange(Status, FinishProposal.Status::MFGReady);
        Results.Set(Format(TempCue.FieldNo("Orders Ready to Finish")), Format(FinishProposal.Count()));

        WipReconciliation.SetRange(Status, WipReconciliation.Status::MFGInvestigate);
        Results.Set(Format(TempCue.FieldNo("WIP to Investigate")), Format(WipReconciliation.Count()));

        RefreshChange.SetRange(Restorable, true);
        RefreshChange.SetRange(Restored, false);
        Results.Set(Format(TempCue.FieldNo("Changes to Restore")), Format(RefreshChange.Count()));

        CostDriftLine.SetRange(Transferred, false);
        Results.Set(Format(TempCue.FieldNo("Cost Drift Lines")), Format(CostDriftLine.Count()));

        ItemPlanningInsight.SetFilter(Advisor, '<>%1', ItemPlanningInsight.Advisor::MFGNone);
        Results.Set(Format(TempCue.FieldNo("Items with Planning Advice")), Format(ItemPlanningInsight.Count()));

        ShopFloorSession.SetRange(Status, ShopFloorSession.Status::MFGRunning);
        Results.Set(Format(TempCue.FieldNo("Operations Running")), Format(ShopFloorSession.Count()));

        EcoHeader.SetRange(Status, EcoHeader.Status::MFGPendingApproval);
        Results.Set(Format(TempCue.FieldNo("ECOs Pending Approval")), Format(EcoHeader.Count()));
        EcoHeader.SetRange(Status, EcoHeader.Status::MFGApproved);
        Results.Set(Format(TempCue.FieldNo("ECOs to Implement")), Format(EcoHeader.Count()));

        LoadPlanLine.SetRange(Late, true);
        Results.Set(Format(TempCue.FieldNo("Late Operations")), Format(LoadPlanLine.Count()));
    end;
}
