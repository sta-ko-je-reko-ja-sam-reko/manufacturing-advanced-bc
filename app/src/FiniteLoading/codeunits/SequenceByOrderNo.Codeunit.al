namespace ManufacturingAdvanced.FiniteLoading;

codeunit 85706 "MFG Sequence By Order No." implements "MFG ISequencer"
{
    Access = Public;

    /// <summary>
    /// Loads operations in production order number order, first in first out.
    /// </summary>
    /// <param name="LoadPlanLine">The load plan lines of one work center.</param>
    procedure Sequence(var LoadPlanLine: Record "MFG Load Plan Line")
    var
        SequenceNo: Integer;
    begin
        LoadPlanLine.SetCurrentKey("Work Center No.", "Prod. Order No.", "Operation No.");
        if not LoadPlanLine.FindSet(true) then
            exit;
        repeat
            SequenceNo += 1;
            LoadPlanLine."Sequence No." := SequenceNo;
            LoadPlanLine.Modify(true);
        until LoadPlanLine.Next() = 0;
    end;
}
