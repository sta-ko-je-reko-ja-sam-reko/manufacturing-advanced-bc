namespace ManufacturingAdvanced.FiniteLoading;

codeunit 85707 "MFG Sequence Shortest First" implements "MFG ISequencer"
{
    Access = Public;

    /// <summary>
    /// Loads the operation that needs the least capacity first, which finishes the most operations soonest.
    /// </summary>
    /// <param name="LoadPlanLine">The load plan lines of one work center.</param>
    procedure Sequence(var LoadPlanLine: Record "MFG Load Plan Line")
    var
        SequenceNo: Integer;
    begin
        LoadPlanLine.SetCurrentKey("Work Center No.", Need, "Due Date");
        if not LoadPlanLine.FindSet(true) then
            exit;
        repeat
            SequenceNo += 1;
            LoadPlanLine."Sequence No." := SequenceNo;
            LoadPlanLine.Modify(true);
        until LoadPlanLine.Next() = 0;
    end;
}
