namespace ManufacturingAdvanced.PlanningInsight;

codeunit 85507 "MFG Planning No Advisor" implements "MFG IPlanningAdvisor"
{
    Access = Public;

    /// <summary>
    /// Has no advice. An advisor value with no implementation of its own never matches.
    /// </summary>
    /// <param name="Insight">Ignored.</param>
    /// <param name="Threshold">Ignored.</param>
    /// <param name="Advice">Cleared.</param>
    /// <returns>Always false.</returns>
    procedure Evaluate(Insight: Record "MFG Item Planning Insight"; Threshold: Integer; var Advice: Text): Boolean
    begin
        Advice := '';
        exit(false);
    end;

    /// <summary>
    /// An advisor with no implementation has nothing to describe.
    /// </summary>
    /// <returns>An empty text.</returns>
    procedure Description(): Text
    begin
        exit('');
    end;
}
