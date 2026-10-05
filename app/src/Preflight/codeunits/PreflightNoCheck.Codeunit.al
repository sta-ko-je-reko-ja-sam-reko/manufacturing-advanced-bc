namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

codeunit 85107 "MFG Preflight No Check" implements "MFG IPreflightCheck"
{
    Access = Public;

    /// <summary>
    /// Finds nothing. A check value with no implementation of its own never reports a problem.
    /// </summary>
    /// <param name="ProductionOrder">Ignored.</param>
    /// <param name="Collector">Left untouched.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    begin
    end;

    /// <summary>
    /// A check with no implementation is off.
    /// </summary>
    /// <returns>Always Off.</returns>
    procedure DefaultSeverity(): Enum "MFG Preflight Severity"
    begin
        exit(Enum::"MFG Preflight Severity"::MFGOff);
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
