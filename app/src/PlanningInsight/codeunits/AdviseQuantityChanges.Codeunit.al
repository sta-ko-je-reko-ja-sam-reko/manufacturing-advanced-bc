namespace ManufacturingAdvanced.PlanningInsight;

codeunit 85511 "MFG Advise Quantity Changes" implements "MFG IPlanningAdvisor"
{
    Access = Public;

    var
        DescriptionLbl: Label 'Planning keeps changing the quantity of the same item''s orders. A dampener quantity lets small changes pass without a message.';
        SetAdviceLbl: Label 'Planning changed the quantity of this item''s orders in %1 of %2 runs. Set a Dampener Quantity so that small differences no longer produce a message.', Comment = '%1 = runs with a quantity change, %2 = runs with any message';
        WidenAdviceLbl: Label 'Planning changed the quantity of this item''s orders in %1 of %2 runs despite a Dampener Quantity of %3. Consider raising it.', Comment = '%1 = runs with a quantity change, %2 = runs with any message, %3 = the current dampener quantity';

    /// <summary>
    /// Advises a dampener quantity when an item's order quantities changed in at least the threshold number of
    /// runs.
    /// </summary>
    /// <param name="Insight">The item's counts and parameters.</param>
    /// <param name="Threshold">How many runs make a pattern.</param>
    /// <param name="Advice">Set to the advice.</param>
    /// <returns>True when the pattern is there.</returns>
    procedure Evaluate(Insight: Record "MFG Item Planning Insight"; Threshold: Integer; var Advice: Text): Boolean
    begin
        Advice := '';
        if Insight."Change Qty. Runs" < Threshold then
            exit(false);

        if Insight."Dampener Quantity" = 0 then
            Advice := StrSubstNo(SetAdviceLbl, Insight."Change Qty. Runs", Insight."Runs With Messages")
        else
            Advice := StrSubstNo(WidenAdviceLbl, Insight."Change Qty. Runs", Insight."Runs With Messages", Insight."Dampener Quantity");
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
