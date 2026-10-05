namespace ManufacturingAdvanced.PlanningInsight;

codeunit 85510 "MFG Advise Reschedules" implements "MFG IPlanningAdvisor"
{
    Access = Public;

    var
        DescriptionLbl: Label 'Planning keeps moving the same item''s orders back and forth. A dampener period lets small date shifts pass without a reschedule message.';
        SetAdviceLbl: Label 'Planning rescheduled this item''s orders in %1 of %2 runs. Set a Dampener Period (for example 1W) so that small date shifts no longer produce a message.', Comment = '%1 = runs with a reschedule, %2 = runs with any message';
        WidenAdviceLbl: Label 'Planning rescheduled this item''s orders in %1 of %2 runs despite a Dampener Period of %3. Consider widening it.', Comment = '%1 = runs with a reschedule, %2 = runs with any message, %3 = the current dampener period';

    /// <summary>
    /// Advises a dampener period when an item was rescheduled in at least the threshold number of runs.
    /// </summary>
    /// <param name="Insight">The item's counts and parameters.</param>
    /// <param name="Threshold">How many runs make a pattern.</param>
    /// <param name="Advice">Set to the advice.</param>
    /// <returns>True when the pattern is there.</returns>
    procedure Evaluate(Insight: Record "MFG Item Planning Insight"; Threshold: Integer; var Advice: Text): Boolean
    begin
        Advice := '';
        if Insight."Reschedule Runs" < Threshold then
            exit(false);

        if Insight."Dampener Period" = '' then
            Advice := StrSubstNo(SetAdviceLbl, Insight."Reschedule Runs", Insight."Runs With Messages")
        else
            Advice := StrSubstNo(WidenAdviceLbl, Insight."Reschedule Runs", Insight."Runs With Messages", Insight."Dampener Period");
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
