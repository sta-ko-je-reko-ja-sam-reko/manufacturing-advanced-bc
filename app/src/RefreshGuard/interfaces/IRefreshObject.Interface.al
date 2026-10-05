namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

interface "MFG IRefreshObject"
{
    /// <summary>
    /// Stores how this kind of production order data looks before a refresh.
    /// </summary>
    /// <param name="RunNo">The refresh run the snapshot belongs to.</param>
    /// <param name="ProductionOrder">The order about to be refreshed.</param>
    procedure TakeSnapshot(RunNo: Integer; ProductionOrder: Record "Production Order");

    /// <summary>
    /// Compares the data after the refresh with the snapshot and records one change per difference.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    procedure Compare(RunNo: Integer; ProductionOrder: Record "Production Order");

    /// <summary>
    /// Puts back what the refresh changed, for one recorded change that is restorable.
    /// </summary>
    /// <param name="Change">The change to undo.</param>
    procedure Restore(Change: Record "MFG Refresh Change");

    /// <summary>
    /// Removes the snapshot rows of a run.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    procedure DeleteSnapshot(RunNo: Integer);
}
