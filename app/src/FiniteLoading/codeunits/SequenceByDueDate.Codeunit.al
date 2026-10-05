namespace ManufacturingAdvanced.FiniteLoading;

codeunit 85705 "MFG Sequence By Due Date" implements "MFG ISequencer"
{
    Access = Public;

    /// <summary>
    /// Loads the operation of the order due first first; operations of one order in operation order.
    /// </summary>
    /// <param name="LoadPlanLine">The load plan lines of one work center.</param>
    procedure Sequence(var LoadPlanLine: Record "MFG Load Plan Line")
    var
        SequenceNo: Integer;
    begin
        LoadPlanLine.SetCurrentKey("Work Center No.", "Due Date", "Prod. Order No.", "Operation No.");
        if not LoadPlanLine.FindSet(true) then
            exit;
        repeat
            SequenceNo += 1;
            LoadPlanLine."Sequence No." := SequenceNo;
            LoadPlanLine.Modify(true);
        until LoadPlanLine.Next() = 0;
    end;
}
