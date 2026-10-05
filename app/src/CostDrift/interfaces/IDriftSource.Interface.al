namespace ManufacturingAdvanced.CostDrift;

interface "MFG IDriftSource"
{
    /// <summary>
    /// Adds one candidate line per standard-cost item this source can price, with the item's current
    /// standard cost and the cost this source proposes. The engine applies the tolerance afterwards.
    /// </summary>
    /// <param name="TempDriftLine">The candidate buffer to add lines to.</param>
    procedure Collect(var TempDriftLine: Record "MFG Cost Drift Line" temporary);

    /// <summary>
    /// Writes one drift line to a standard cost worksheet in the shape the standard Implement Standard Cost
    /// Changes expects, creating or updating the item's worksheet line.
    /// </summary>
    /// <param name="DriftLine">The drift line.</param>
    /// <param name="WorksheetName">The standard cost worksheet to write to.</param>
    procedure TransferToWorksheet(DriftLine: Record "MFG Cost Drift Line"; WorksheetName: Code[10]);

    /// <summary>
    /// What the source compares, in a sentence a cost accountant understands.
    /// </summary>
    /// <returns>The description shown on the source list.</returns>
    procedure Description(): Text;
}
