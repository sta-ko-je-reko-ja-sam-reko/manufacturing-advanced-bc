namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

interface "MFG IGLWipSource"
{
    /// <summary>
    /// Returns what the general ledger holds on the WIP accounts for a production order.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    /// <returns>The net amount posted to WIP accounts for the order.</returns>
    procedure GLWipAmount(ProductionOrder: Record "Production Order"): Decimal;

    /// <summary>
    /// Returns how much of the order's actual cost has not been posted to the general ledger yet.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    /// <returns>The actual cost not yet posted to the general ledger.</returns>
    procedure UnpostedCost(ProductionOrder: Record "Production Order"): Decimal;
}
