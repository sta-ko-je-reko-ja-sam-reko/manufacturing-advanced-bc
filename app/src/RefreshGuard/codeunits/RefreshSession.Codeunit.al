namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85406 "MFG Refresh Session"
{
    Access = Internal;
    SingleInstance = true;

    var
        OpenRuns: Dictionary of [Text, Integer];
        LineRuns: Dictionary of [Text, Integer];
        OrderKeyTok: Label '%1|%2', Locked = true;
        LineKeyTok: Label '%1|%2|%3', Locked = true;

    /// <summary>
    /// Remembers the run started for an order, until the refresh of that order completes.
    /// </summary>
    /// <param name="ProductionOrder">The order being refreshed.</param>
    /// <param name="RunNo">The run started for it.</param>
    internal procedure Remember(ProductionOrder: Record "Production Order"; RunNo: Integer)
    begin
        OpenRuns.Set(OrderKey(ProductionOrder), RunNo);
    end;

    /// <summary>
    /// Returns and forgets the run started for an order.
    /// </summary>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    /// <param name="RunNo">The run started for it.</param>
    /// <returns>True when a run was started for the order.</returns>
    internal procedure Take(ProductionOrder: Record "Production Order"; var RunNo: Integer): Boolean
    begin
        if not OpenRuns.Get(OrderKey(ProductionOrder), RunNo) then
            exit(false);
        OpenRuns.Remove(OrderKey(ProductionOrder));
        exit(true);
    end;

    /// <summary>
    /// Returns whether a Refresh Production Order run is open for the order. A run that was rolled back by an error
    /// no longer exists and does not count.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    /// <returns>True when the order is being refreshed.</returns>
    internal procedure IsOpen(ProductionOrder: Record "Production Order"): Boolean
    var
        RefreshRun: Record "MFG Refresh Run";
        RunNo: Integer;
    begin
        if not OpenRuns.Get(OrderKey(ProductionOrder), RunNo) then
            exit(false);
        if RefreshRun.Get(RunNo) then
            exit(not RefreshRun.Completed);
        OpenRuns.Remove(OrderKey(ProductionOrder));
        exit(false);
    end;

    /// <summary>
    /// Remembers the run started for the recalculation of one order line, until that recalculation completes.
    /// </summary>
    /// <param name="ProdOrderLine">The line being recalculated.</param>
    /// <param name="RunNo">The run started for it.</param>
    internal procedure RememberLine(ProdOrderLine: Record "Prod. Order Line"; RunNo: Integer)
    begin
        LineRuns.Set(LineKey(ProdOrderLine), RunNo);
    end;

    /// <summary>
    /// Returns and forgets the run started for the recalculation of one order line.
    /// </summary>
    /// <param name="ProdOrderLine">The line that was recalculated.</param>
    /// <param name="RunNo">The run started for it.</param>
    /// <returns>True when a run was started for the line.</returns>
    internal procedure TakeLine(ProdOrderLine: Record "Prod. Order Line"; var RunNo: Integer): Boolean
    begin
        if not LineRuns.Get(LineKey(ProdOrderLine), RunNo) then
            exit(false);
        LineRuns.Remove(LineKey(ProdOrderLine));
        exit(true);
    end;

    local procedure LineKey(ProdOrderLine: Record "Prod. Order Line"): Text
    begin
        exit(StrSubstNo(LineKeyTok, ProdOrderLine.Status.AsInteger(), ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No."));
    end;

    local procedure OrderKey(ProductionOrder: Record "Production Order"): Text
    begin
        exit(StrSubstNo(OrderKeyTok, ProductionOrder.Status.AsInteger(), ProductionOrder."No."));
    end;
}
