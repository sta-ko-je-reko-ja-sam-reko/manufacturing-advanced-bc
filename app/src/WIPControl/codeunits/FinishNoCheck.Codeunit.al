namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

codeunit 85206 "MFG Finish No Check" implements "MFG IFinishCheck"
{
    Access = Public;

    /// <summary>
    /// Finds nothing. A check value with no implementation of its own never reports a problem.
    /// </summary>
    /// <param name="ProductionOrder">Ignored.</param>
    /// <param name="Reason">Cleared.</param>
    /// <returns>Always false.</returns>
    procedure Evaluate(ProductionOrder: Record "Production Order"; var Reason: Text): Boolean
    begin
        Reason := '';
        exit(false);
    end;

    /// <summary>
    /// A check with no implementation is off.
    /// </summary>
    /// <returns>Always Off.</returns>
    procedure DefaultSeverity(): Enum "MFG Finish Check Severity"
    begin
        exit(Enum::"MFG Finish Check Severity"::MFGOff);
    end;

    /// <summary>
    /// A check with no implementation has nothing to describe.
    /// </summary>
    /// <returns>An empty text.</returns>
    procedure Description(): Text
    begin
        exit('');
    end;
}
