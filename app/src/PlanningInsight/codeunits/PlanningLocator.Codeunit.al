namespace ManufacturingAdvanced.PlanningInsight;

codeunit 85504 "MFG Planning Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IReactions: Interface "MFG IPlanningReactions";
        IReactionsDefined: Boolean;

    /// <summary>
    /// Returns the implementation that reacts to a finished planning calculation, defaulting to the built-in one.
    /// </summary>
    /// <returns>The reactions implementation for this session.</returns>
    procedure Reactions(): Interface "MFG IPlanningReactions"
    var
        DefaultReactions: Codeunit "MFG Planning Reactions";
    begin
        if not IReactionsDefined then
            Implement(DefaultReactions);
        exit(IReactions);
    end;

    /// <summary>
    /// Replaces the reactions implementation for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure Implement(Implementation: Interface "MFG IPlanningReactions")
    begin
        IReactions := Implementation;
        IReactionsDefined := true;
    end;
}
