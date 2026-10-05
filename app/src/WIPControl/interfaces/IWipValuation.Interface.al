namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

interface "MFG IWipValuation"
{
    /// <summary>
    /// Fills the cost and work-in-progress fields of a finish proposal, and the date of the last output,
    /// for the order it belongs to.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    /// <param name="Proposal">The proposal whose consumption, capacity, output, WIP and last output fields are set.</param>
    procedure Calculate(ProductionOrder: Record "Production Order"; var Proposal: Record "MFG Finish Proposal");
}
