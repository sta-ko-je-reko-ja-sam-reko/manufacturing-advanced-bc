namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85409 "MFG Refresh No Object" implements "MFG IRefreshObject"
{
    Access = Public;

    /// <summary>
    /// Takes no snapshot. An object kind with no implementation of its own records nothing.
    /// </summary>
    /// <param name="RunNo">Ignored.</param>
    /// <param name="ProductionOrder">Ignored.</param>
    procedure TakeSnapshot(RunNo: Integer; ProductionOrder: Record "Production Order")
    begin
    end;

    /// <summary>
    /// Records no change.
    /// </summary>
    /// <param name="RunNo">Ignored.</param>
    /// <param name="ProductionOrder">Ignored.</param>
    procedure Compare(RunNo: Integer; ProductionOrder: Record "Production Order")
    begin
    end;

    /// <summary>
    /// Restores nothing.
    /// </summary>
    /// <param name="Change">Ignored.</param>
    procedure Restore(Change: Record "MFG Refresh Change")
    begin
    end;

    /// <summary>
    /// Deletes nothing.
    /// </summary>
    /// <param name="RunNo">Ignored.</param>
    procedure DeleteSnapshot(RunNo: Integer)
    begin
    end;
}
