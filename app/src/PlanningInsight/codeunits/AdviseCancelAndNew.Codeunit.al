namespace ManufacturingAdvanced.PlanningInsight;

codeunit 85512 "MFG Advise Cancel And New" implements "MFG IPlanningAdvisor"
{
    Access = Public;

    var
        DescriptionLbl: Label 'Planning keeps cancelling the same item''s orders and proposing new ones. A longer lot accumulation or rescheduling period lets it reuse the orders that exist.';
        AdviceLbl: Label 'Planning cancelled this item''s orders in %1 runs and proposed new ones in %2. Lengthen the Lot Accumulation Period (now %3) or the Rescheduling Period (now %4) so that existing orders are moved instead of replaced.', Comment = '%1 = runs with a cancel, %2 = runs with a new order, %3 = the current lot accumulation period, %4 = the current rescheduling period';

    /// <summary>
    /// Advises longer accumulation or rescheduling periods when an item got both cancellations and new orders in
    /// at least the threshold number of runs.
    /// </summary>
    /// <param name="Insight">The item's counts and parameters.</param>
    /// <param name="Threshold">How many runs make a pattern.</param>
    /// <param name="Advice">Set to the advice.</param>
    /// <returns>True when the pattern is there.</returns>
    procedure Evaluate(Insight: Record "MFG Item Planning Insight"; Threshold: Integer; var Advice: Text): Boolean
    begin
        Advice := '';
        if (Insight."Cancel Runs" < Threshold) or (Insight."New Runs" < Threshold) then
            exit(false);

        Advice := StrSubstNo(AdviceLbl, Insight."Cancel Runs", Insight."New Runs", Insight."Lot Accumulation Period", Insight."Rescheduling Period");
        exit(true);
    end;

    /// <summary>
    /// Describes the pattern.
    /// </summary>
    /// <returns>The description.</returns>
    procedure Description(): Text
    begin
        exit(DescriptionLbl);
    end;
}
