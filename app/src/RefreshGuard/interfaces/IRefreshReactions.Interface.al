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
}
