namespace ManufacturingAdvanced.PlanningInsight;

interface "MFG IPlanningAdvisor"
{
    /// <summary>
    /// Looks at an item's action message history and its planning parameters, and says what to change when
    /// the pattern this advisor knows is there.
    /// </summary>
    /// <param name="Insight">The item's counts, with its planning parameters filled in.</param>
    /// <param name="Threshold">How many runs with a message make a pattern.</param>
    /// <param name="Advice">Set to the advice when the pattern is there.</param>
    /// <returns>True when the advisor has advice.</returns>
    procedure Evaluate(Insight: Record "MFG Item Planning Insight"; Threshold: Integer; var Advice: Text): Boolean;

    /// <summary>
    /// What pattern the advisor looks for, in a sentence a planner understands.
    /// </summary>
    /// <returns>The description shown on the rule list.</returns>
    procedure Description(): Text;
}
