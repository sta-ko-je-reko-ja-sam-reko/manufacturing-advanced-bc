namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

codeunit 85402 "MFG Refresh Engine"
{
    Access = Public;

    var
        NotRestorableErr: Label 'This change cannot be restored by the app. Re-enter it on the production order by hand.';
        AlreadyRestoredErr: Label 'This change has already been restored.';

    /// <summary>
    /// Starts a refresh run for a production order: records the run and asks every object kind to take its
    /// snapshot. Call before the order's lines are recalculated.
    /// </summary>
    /// <param name="ProductionOrder">The order about to be refreshed.</param>
    /// <returns>The number of the run.</returns>
    procedure BeginRun(ProductionOrder: Record "Production Order"): Integer
    begin
        exit(BeginRun(ProductionOrder, Enum::"MFG Refresh Source"::MFGRefreshReport));
    end;

    /// <summary>
    /// Starts a refresh run for a production order, recording what recalculates it.
    /// </summary>
    /// <param name="ProductionOrder">The order about to be recalculated.</param>
    /// <param name="Source">What recalculates it.</param>
    /// <returns>The number of the run.</returns>
    procedure BeginRun(ProductionOrder: Record "Production Order"; Source: Enum "MFG Refresh Source"): Integer
    var
        RefreshRun: Record "MFG Refresh Run";
        RefreshObject: Interface "MFG IRefreshObject";
        Ordinal: Integer;
    begin
        RefreshRun.Init();
        RefreshRun.Source := Source;
        RefreshRun."Prod. Order Status" := ProductionOrder.Status;
        RefreshRun."Prod. Order No." := ProductionOrder."No.";
        RefreshRun."Refreshed At" := CurrentDateTime();
        RefreshRun."Refreshed By" := CopyStr(UserId(), 1, MaxStrLen(RefreshRun."Refreshed By"));
        RefreshRun.Insert(true);

        foreach Ordinal in Enum::"MFG Refresh Object Kind".Ordinals() do begin
            RefreshObject := Enum::"MFG Refresh Object Kind".FromInteger(Ordinal);
            RefreshObject.TakeSnapshot(RefreshRun."Run No.", ProductionOrder);
        end;
        exit(RefreshRun."Run No.");
    end;

    /// <summary>
    /// Completes a refresh run: asks every object kind to compare the order with its snapshot and record the
    /// differences. A run without differences is removed with its snapshot.
    /// </summary>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    /// <param name="RunNo">The run started before the refresh.</param>
    /// <returns>The number of changes the refresh made.</returns>
    procedure CompleteRun(ProductionOrder: Record "Production Order"; RunNo: Integer): Integer
    var
        RefreshRun: Record "MFG Refresh Run";
        RefreshObject: Interface "MFG IRefreshObject";
        Ordinal: Integer;
    begin
        if not RefreshRun.Get(RunNo) then
            exit(0);

        foreach Ordinal in Enum::"MFG Refresh Object Kind".Ordinals() do begin
            RefreshObject := Enum::"MFG Refresh Object Kind".FromInteger(Ordinal);
            RefreshObject.Compare(RunNo, ProductionOrder);
        end;

        RefreshRun.CalcFields(Changes);
        if RefreshRun.Changes = 0 then begin
            DeleteRun(RunNo);
            exit(0);
        end;

        RefreshRun.Completed := true;
        RefreshRun.Modify(true);
        exit(RefreshRun.Changes);
    end;

    /// <summary>
    /// Records one change of a run, numbering it within the run.
    /// </summary>
    /// <param name="Change">The change to insert; its run number must be set.</param>
    procedure InsertChange(var Change: Record "MFG Refresh Change")
    var
        LastChange: Record "MFG Refresh Change";
    begin
        LastChange.SetRange("Run No.", Change."Run No.");
        if LastChange.FindLast() then
            Change."Entry No." := LastChange."Entry No." + 1
        else
            Change."Entry No." := 1;
        Change.Insert(true);
    end;

    /// <summary>
    /// Puts back what the refresh changed, for one restorable change, through the object kind it belongs to.
    /// </summary>
    /// <param name="Change">The change to undo.</param>
    procedure Restore(var Change: Record "MFG Refresh Change")
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        RefreshObject: Interface "MFG IRefreshObject";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGRefreshGuard);
        if not Change.Restorable then
            Error(NotRestorableErr);
        if Change.Restored then
            Error(AlreadyRestoredErr);

        RefreshObject := Change.Kind;
        RefreshObject.Restore(Change);

        Change.Restored := true;
        Change.Modify(true);
    end;

    /// <summary>
    /// Restores every change in the filter that is restorable and not restored yet.
    /// </summary>
    /// <param name="Change">The changes, filtered.</param>
    /// <returns>The number of changes restored.</returns>
    procedure RestoreAll(var Change: Record "MFG Refresh Change"): Integer
    var
        ToRestore: Record "MFG Refresh Change";
        Restored: Integer;
    begin
        ToRestore.CopyFilters(Change);
        ToRestore.SetRange(Restorable, true);
        ToRestore.SetRange(Restored, false);
        if not ToRestore.FindSet() then
            exit(0);

        repeat
            Restore(ToRestore);
            Restored += 1;
        until ToRestore.Next() = 0;
        exit(Restored);
    end;

    /// <summary>
    /// Removes a run with its changes and snapshots.
    /// </summary>
    /// <param name="RunNo">The run.</param>
    procedure DeleteRun(RunNo: Integer)
    var
        RefreshRun: Record "MFG Refresh Run";
        Change: Record "MFG Refresh Change";
        RefreshObject: Interface "MFG IRefreshObject";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Refresh Object Kind".Ordinals() do begin
            RefreshObject := Enum::"MFG Refresh Object Kind".FromInteger(Ordinal);
            RefreshObject.DeleteSnapshot(RunNo);
        end;

        Change.SetRange("Run No.", RunNo);
        Change.DeleteAll(true);
        if RefreshRun.Get(RunNo) then
            RefreshRun.Delete(true);
    end;
}
