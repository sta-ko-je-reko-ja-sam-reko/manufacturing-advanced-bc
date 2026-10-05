namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Manufacturing.Document;

interface "MFG IEcoOrderRefresh"
{
    /// <summary>
    /// Recalculates the routing and components of a production order impacted by an implemented change, so that it
    /// picks up the versions valid on its dates.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    procedure Refresh(ProductionOrder: Record "Production Order");
}
