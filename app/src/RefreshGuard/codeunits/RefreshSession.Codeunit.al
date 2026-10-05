namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85406 "MFG Refresh Session"
{
    Access = Internal;
    SingleInstance = true;

    var
        OpenRuns: Dictionary of [Text, Integer];
        OrderKeyTok: Label '%1|%2', Locked = true;

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

    local procedure OrderKey(ProductionOrder: Record "Production Order"): Text
    begin
        exit(StrSubstNo(OrderKeyTok, ProductionOrder.Status.AsInteger(), ProductionOrder."No."));
    end;
}
