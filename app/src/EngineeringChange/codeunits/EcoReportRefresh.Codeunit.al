namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Manufacturing.Document;

codeunit 85812 "MFG ECO Report Refresh" implements "MFG IEcoOrderRefresh"
{
    Access = Public;

    /// <summary>
    /// Runs the standard Refresh Production Order for the order, backward, recalculating routing and components but
    /// not the lines, without the request page. Refresh Protection, when enabled, records what the refresh changes.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    procedure Refresh(ProductionOrder: Record "Production Order")
    var
        RefreshProductionOrder: Report "Refresh Production Order";
        Direction: Option Forward,Backward;
    begin
        ProductionOrder.SetRecFilter();
        RefreshProductionOrder.SetTableView(ProductionOrder);
        RefreshProductionOrder.InitializeRequest(Direction::Backward, false, true, true, false);
        RefreshProductionOrder.UseRequestPage(false);
        RefreshProductionOrder.RunModal();
    end;
}
