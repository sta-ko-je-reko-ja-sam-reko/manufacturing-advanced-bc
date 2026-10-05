namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

interface "MFG IPreflightCheck"
{
    /// <summary>
    /// Inspects a production order and reports every problem this check is responsible for. Must not
    /// change the order or any other record.
    /// </summary>
    /// <param name="ProductionOrder">The production order to inspect.</param>
    /// <param name="Collector">Receives the findings; it already knows the check and the severity.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector");

    /// <summary>
    /// The severity the check starts with when its configuration row is first created.
    /// </summary>
    /// <returns>The default severity.</returns>
    procedure DefaultSeverity(): Enum "MFG Preflight Severity";

    /// <summary>
    /// What the check looks for, in a sentence a production planner understands.
    /// </summary>
    /// <returns>The description shown on the check list.</returns>
    procedure Description(): Text;
}
