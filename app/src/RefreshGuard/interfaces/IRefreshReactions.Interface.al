namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

interface "MFG IRefreshReactions"
{
    /// <summary>
    /// Reacts to a production order that is about to be refreshed, before any line is deleted.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    procedure OnBeforeRefresh(var ProductionOrder: Record "Production Order");

    /// <summary>
    /// Reacts to a production order that has been refreshed.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    procedure OnAfterRefresh(var ProductionOrder: Record "Production Order");

    /// <summary>
    /// Reacts to one production order line about to be recalculated from its BOM and routing outside the Refresh
    /// Production Order batch job.
    /// </summary>
    /// <param name="ProdOrderLine">The line.</param>
    /// <param name="CalcRouting">Whether its routing is recalculated.</param>
    /// <param name="CalcComponents">Whether its components are recalculated.</param>
    procedure OnBeforeCalculateLine(ProdOrderLine: Record "Prod. Order Line"; CalcRouting: Boolean; CalcComponents: Boolean);

    /// <summary>
    /// Reacts to one production order line that has been recalculated.
    /// </summary>
    /// <param name="ProdOrderLine">The line.</param>
    procedure OnAfterCalculateLine(ProdOrderLine: Record "Prod. Order Line");
}
