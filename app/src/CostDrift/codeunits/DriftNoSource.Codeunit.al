namespace ManufacturingAdvanced.CostDrift;

codeunit 85303 "MFG Drift No Source" implements "MFG IDriftSource"
{
    Access = Public;

    /// <summary>
    /// Adds nothing. A source value with no implementation of its own proposes no cost.
    /// </summary>
    /// <param name="TempDriftLine">Left untouched.</param>
    procedure Collect(var TempDriftLine: Record "MFG Cost Drift Line" temporary)
    begin
    end;

    /// <summary>
    /// Writes nothing.
    /// </summary>
    /// <param name="DriftLine">Ignored.</param>
    /// <param name="WorksheetName">Ignored.</param>
    procedure TransferToWorksheet(DriftLine: Record "MFG Cost Drift Line"; WorksheetName: Code[10])
    begin
    end;

    /// <summary>
    /// A source with no implementation has nothing to describe.
    /// </summary>
    /// <returns>An empty text.</returns>
    procedure Description(): Text
    begin
        exit('');
    end;
}
