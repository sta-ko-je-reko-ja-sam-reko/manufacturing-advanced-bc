namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

interface "MFG IFinishCheck"
{
    /// <summary>
    /// Inspects a released production order that is a candidate for finishing. Must not change anything.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    /// <param name="Reason">Set to what is wrong and what to do about it when the check finds something.</param>
    /// <returns>True when the check found something.</returns>
    procedure Evaluate(ProductionOrder: Record "Production Order"; var Reason: Text): Boolean;

    /// <summary>
    /// The severity the check starts with when its configuration row is first created.
    /// </summary>
    /// <returns>The default severity.</returns>
    procedure DefaultSeverity(): Enum "MFG Finish Check Severity";

    /// <summary>
    /// What the check looks for, in a sentence a production controller understands.
    /// </summary>
    /// <returns>The description shown on the check list.</returns>
    procedure Description(): Text;
}
