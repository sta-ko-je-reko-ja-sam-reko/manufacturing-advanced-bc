namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;

codeunit 85802 "MFG ECO Engine"
{
    Access = Public;

    var
        WrongStatusErr: Label 'Engineering change %1 is %2. This step needs it to be %3.', Comment = '%1 = the change number, %2 = its status, %3 = the status needed';
        NoLinesErr: Label 'Engineering change %1 has no lines.', Comment = '%1 = the change number';
        NoVersionErr: Label 'Line %1 of engineering change %2 has no new version yet. Choose Create versions first.', Comment = '%1 = the line number, %2 = the change number';
        OrderKeyTok: Label '%1|%2', Locked = true;
        NoEffectiveDateErr: Label 'Enter the effective date of engineering change %1.', Comment = '%1 = the change number';

    /// <summary>
    /// Creates, for every line that has none yet, the new BOM or routing version the change is made in.
    /// </summary>
    /// <param name="EcoHeader">The change, which must be open.</param>
    /// <returns>The number of lines with a new version.</returns>
    procedure CreateVersions(var EcoHeader: Record "MFG ECO Header"): Integer
    var
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGOpen);
        FindLines(EcoHeader, EcoLine);
        repeat
            EcoObject := EcoLine."Object Type";
            EcoObject.CreateVersion(EcoLine);
        until EcoLine.Next() = 0;
        exit(EcoLine.Count());
    end;

    /// <summary>
    /// Sends an open change for approval, once every line has its new version and the effective date is set, through
    /// the approval method of the setup: on the change card, or through an approval workflow.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure SubmitForApproval(var EcoHeader: Record "MFG ECO Header")
    var
        EcoLine: Record "MFG ECO Line";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGOpen);
        if EcoHeader."Effective Date" = 0D then
            Error(NoEffectiveDateErr, EcoHeader."No.");
        FindLines(EcoHeader, EcoLine);
        repeat
            if EcoLine."New Version Code" = '' then
                Error(NoVersionErr, EcoLine."Line No.", EcoHeader."No.");
        until EcoLine.Next() = 0;

        ApprovalMethod().Submit(EcoHeader);
    end;

    /// <summary>
    /// Approves a change pending approval on the change card. The approval method decides whether the current user
    /// may: on the card with a separate approver, not the requester; under an approval workflow, nobody, because
    /// approvers decide in Requests to Approve.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Approve(var EcoHeader: Record "MFG ECO Header")
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
        ApprovalMethod().CheckDirectDecision(EcoHeader);
        MarkApproved(EcoHeader);
    end;

    /// <summary>
    /// Rejects a change pending approval on the change card, under the same rule as approving.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Reject(var EcoHeader: Record "MFG ECO Header")
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
        ApprovalMethod().CheckDirectDecision(EcoHeader);
        MarkRejected(EcoHeader);
    end;

    /// <summary>
    /// Puts a pending or rejected change back to open, so it can be edited and submitted again. A pending approval
    /// request is withdrawn first through the approval method.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Reopen(var EcoHeader: Record "MFG ECO Header")
    begin
        CheckEnabled();
        if not (EcoHeader.Status in [EcoHeader.Status::MFGPendingApproval, EcoHeader.Status::MFGRejected]) then
            CheckStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
        ApprovalMethod().Cancel(EcoHeader);
        MarkOpen(EcoHeader);
    end;

    /// <summary>
    /// Sets a change to pending approval. Called by the approval methods and the workflow response.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure MarkPendingApproval(var EcoHeader: Record "MFG ECO Header")
    begin
        SetStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
    end;

    /// <summary>
    /// Sets a change to approved by the current user. Called on the card and by the workflow response that runs when
    /// the last approver approves.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure MarkApproved(var EcoHeader: Record "MFG ECO Header")
    begin
        EcoHeader."Approved By" := CopyStr(UserId(), 1, MaxStrLen(EcoHeader."Approved By"));
        EcoHeader."Approved At" := CurrentDateTime();
        SetStatus(EcoHeader, EcoHeader.Status::MFGApproved);
    end;

    /// <summary>
    /// Sets a change to rejected by the current user.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure MarkRejected(var EcoHeader: Record "MFG ECO Header")
    begin
        EcoHeader."Approved By" := CopyStr(UserId(), 1, MaxStrLen(EcoHeader."Approved By"));
        EcoHeader."Approved At" := CurrentDateTime();
        SetStatus(EcoHeader, EcoHeader.Status::MFGRejected);
    end;

    /// <summary>
    /// Sets a change back to open and clears its decision. Called on reopening and by the workflow response that
    /// runs when a request is rejected or canceled.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure MarkOpen(var EcoHeader: Record "MFG ECO Header")
    begin
        EcoHeader."Approved By" := '';
        EcoHeader."Approved At" := 0DT;
        SetStatus(EcoHeader, EcoHeader.Status::MFGOpen);
    end;

    /// <summary>
    /// Implements an approved change: certifies every new version, starting on the effective date.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Implement(var EcoHeader: Record "MFG ECO Header")
    var
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGApproved);
        FindLines(EcoHeader, EcoLine);
        repeat
            EcoObject := EcoLine."Object Type";
            EcoObject.Certify(EcoLine, EcoHeader."Effective Date");
        until EcoLine.Next() = 0;

        EcoHeader.Get(EcoHeader."No.");
        EcoHeader."Implemented At" := CurrentDateTime();
        SetStatus(EcoHeader, EcoHeader.Status::MFGImplemented);
    end;

    /// <summary>
    /// Refreshes the production orders an implemented change impacts, once each, so they pick up the versions valid
    /// on their dates. Skipped: orders due before the effective date, which keep the old versions anyway, and
    /// released orders with posted entries, which Business Central does not recalculate.
    /// </summary>
    /// <param name="EcoHeader">The implemented change.</param>
    /// <param name="Refreshed">Returns the number of orders refreshed.</param>
    /// <param name="Skipped">Returns the number of impacted orders left alone.</param>
    procedure RefreshImpactedOrders(EcoHeader: Record "MFG ECO Header"; var Refreshed: Integer; var Skipped: Integer)
    var
        TempImpact: Record "MFG ECO Impact" temporary;
        ProductionOrder: Record "Production Order";
        Locator: Codeunit "MFG ECO Locator";
        OrderRefresh: Interface "MFG IEcoOrderRefresh";
        Done: List of [Text];
        OrderKey: Text;
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGImplemented);
        Refreshed := 0;
        Skipped := 0;
        OrderRefresh := Locator.OrderRefresh();

        GetImpact(EcoHeader, TempImpact);
        if not TempImpact.FindSet() then
            exit;
        repeat
            OrderKey := StrSubstNo(OrderKeyTok, TempImpact."Prod. Order Status".AsInteger(), TempImpact."Prod. Order No.");
            if not Done.Contains(OrderKey) then begin
                Done.Add(OrderKey);
                if ProductionOrder.Get(TempImpact."Prod. Order Status", TempImpact."Prod. Order No.") then
                    if MustRefresh(ProductionOrder, EcoHeader."Effective Date") then begin
                        OrderRefresh.Refresh(ProductionOrder);
                        Refreshed += 1;
                    end else
                        Skipped += 1;
            end;
        until TempImpact.Next() = 0;
    end;

    /// <summary>
    /// Lists the open production order lines that use any BOM or routing the change touches.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    /// <param name="TempImpact">Receives the impact; existing contents are discarded.</param>
    procedure GetImpact(EcoHeader: Record "MFG ECO Header"; var TempImpact: Record "MFG ECO Impact" temporary)
    var
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
    begin
        TempImpact.Reset();
        TempImpact.DeleteAll();
        EcoLine.SetRange("ECO No.", EcoHeader."No.");
        if not EcoLine.FindSet() then
            exit;
        repeat
            EcoObject := EcoLine."Object Type";
            EcoObject.CollectImpact(EcoLine, TempImpact);
        until EcoLine.Next() = 0;
        TempImpact.Reset();
    end;

    local procedure MustRefresh(ProductionOrder: Record "Production Order"; EffectiveDate: Date): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if ProductionOrder."Due Date" < EffectiveDate then
            exit(false);
        if ProductionOrder.Status <> ProductionOrder.Status::Released then
            exit(true);
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", ProductionOrder."No.");
        exit(ItemLedgerEntry.IsEmpty());
    end;

    local procedure FindLines(EcoHeader: Record "MFG ECO Header"; var EcoLine: Record "MFG ECO Line")
    begin
        EcoLine.SetRange("ECO No.", EcoHeader."No.");
        EcoLine.SetFilter("No.", '<>%1', '');
        if not EcoLine.FindSet() then
            Error(NoLinesErr, EcoHeader."No.");
    end;

    local procedure CheckStatus(EcoHeader: Record "MFG ECO Header"; Expected: Enum "MFG ECO Status")
    begin
        if EcoHeader.Status <> Expected then
            Error(WrongStatusErr, EcoHeader."No.", EcoHeader.Status, Expected);
    end;

    local procedure SetStatus(var EcoHeader: Record "MFG ECO Header"; NewStatus: Enum "MFG ECO Status")
    begin
        EcoHeader.Status := NewStatus;
        EcoHeader.Modify(true);
    end;

    local procedure ApprovalMethod(): Interface "MFG IEcoApproval"
    var
        Setup: Record "MFG ECO Setup";
    begin
        Setup.SetLoadFields("Approval Method");
        if not Setup.Get() then
            Clear(Setup);
        exit(Setup."Approval Method");
    end;

    local procedure CheckEnabled()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGEngineeringChange);
    end;
}
