namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

codeunit 85403 "MFG Refresh Reactions" implements "MFG IRefreshReactions"
{
    Access = Public;

    /// <summary>
    /// Takes the snapshot of an order about to be refreshed. Does nothing while the feature is off.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    procedure OnBeforeRefresh(var ProductionOrder: Record "Production Order")
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Refresh Engine";
        Session: Codeunit "MFG Refresh Session";
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGRefreshGuard) then
            exit;

        Session.Remember(ProductionOrder, Engine.BeginRun(ProductionOrder));
    end;

    /// <summary>
    /// Compares the refreshed order with its snapshot and, when the refresh changed something and the setup
    /// asks for it, tells the user. Does nothing while the feature is off or when no snapshot was taken.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    procedure OnAfterRefresh(var ProductionOrder: Record "Production Order")
    var
        Setup: Record "MFG Refresh Setup";
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Refresh Engine";
        Session: Codeunit "MFG Refresh Session";
        RefreshNotification: Codeunit "MFG Refresh Notification";
        RunNo: Integer;
        ChangeCount: Integer;
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGRefreshGuard) then
            exit;
        if not Session.Take(ProductionOrder, RunNo) then
            exit;

        ChangeCount := Engine.CompleteRun(ProductionOrder, RunNo);
        if ChangeCount = 0 then
            exit;

        Setup.SetLoadFields("Notify on Changes");
        if Setup.Get() then
            if Setup."Notify on Changes" and GuiAllowed() then
                RefreshNotification.Send(ProductionOrder, RunNo, ChangeCount);
    end;

    /// <summary>
    /// Starts a run when a line that already has components or operations is about to be rebuilt from its BOM and
    /// routing by anything other than Refresh Production Order, whose own run already covers the order. A new line
    /// has nothing to protect and starts none.
    /// </summary>
    /// <param name="ProdOrderLine">The line.</param>
    /// <param name="CalcRouting">Whether its routing is recalculated.</param>
    /// <param name="CalcComponents">Whether its components are recalculated.</param>
    procedure OnBeforeCalculateLine(ProdOrderLine: Record "Prod. Order Line"; CalcRouting: Boolean; CalcComponents: Boolean)
    var
        ProductionOrder: Record "Production Order";
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Refresh Engine";
        Session: Codeunit "MFG Refresh Session";
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGRefreshGuard) then
            exit;
        if not ProductionOrder.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.") then
            exit;
        if Session.IsOpen(ProductionOrder) then
            exit;
        if not HasDataToProtect(ProdOrderLine, CalcRouting, CalcComponents) then
            exit;

        Session.RememberLine(ProdOrderLine, Engine.BeginRun(ProductionOrder, Enum::"MFG Refresh Source"::MFGCalculation));
    end;

    /// <summary>
    /// Completes the run started for the line. The changes are listed on the order's refresh changes; no
    /// notification is sent, because such recalculations often run in batches.
    /// </summary>
    /// <param name="ProdOrderLine">The line.</param>
    procedure OnAfterCalculateLine(ProdOrderLine: Record "Prod. Order Line")
    var
        ProductionOrder: Record "Production Order";
        Engine: Codeunit "MFG Refresh Engine";
        Session: Codeunit "MFG Refresh Session";
        RunNo: Integer;
    begin
        if not Session.TakeLine(ProdOrderLine, RunNo) then
            exit;
        if ProductionOrder.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.") then
            Engine.CompleteRun(ProductionOrder, RunNo);
    end;

    local procedure HasDataToProtect(ProdOrderLine: Record "Prod. Order Line"; CalcRouting: Boolean; CalcComponents: Boolean): Boolean
    var
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        if CalcComponents then begin
            ProdOrderComponent.SetRange(Status, ProdOrderLine.Status);
            ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if not ProdOrderComponent.IsEmpty() then
                exit(true);
        end;
        if CalcRouting then begin
            ProdOrderRoutingLine.SetRange(Status, ProdOrderLine.Status);
            ProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
            ProdOrderRoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
            if not ProdOrderRoutingLine.IsEmpty() then
                exit(true);
        end;
        exit(false);
    end;
}
