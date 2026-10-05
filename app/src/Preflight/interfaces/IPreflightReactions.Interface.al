namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

interface "MFG IPreflightReactions"
{
    /// <summary>
    /// Reacts to a production order that is about to change status. The default implementation runs the
    /// pre-flight checks when the order is being released, and blocks or warns as the setup says.
    /// </summary>
    /// <param name="ProductionOrder">The order whose status is about to change.</param>
    /// <param name="NewStatus">The status it is changing to.</param>
    procedure OnBeforeChangeStatus(var ProductionOrder: Record "Production Order"; NewStatus: Enum "Production Order Status");
}
