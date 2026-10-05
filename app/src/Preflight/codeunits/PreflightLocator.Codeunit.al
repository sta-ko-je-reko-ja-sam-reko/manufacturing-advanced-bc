namespace ManufacturingAdvanced.Preflight;

codeunit 85104 "MFG Preflight Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IReactions: Interface "MFG IPreflightReactions";
        IReactionsDefined: Boolean;

    /// <summary>
    /// Returns the implementation that reacts to production order status changes, defaulting to the
    /// built-in one.
    /// </summary>
    /// <returns>The reactions implementation for this session.</returns>
    procedure Reactions(): Interface "MFG IPreflightReactions"
    var
        DefaultReactions: Codeunit "MFG Preflight Reactions";
    begin
        if not IReactionsDefined then
            Implement(DefaultReactions);
        exit(IReactions);
    end;

    /// <summary>
    /// Replaces the reactions implementation for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure Implement(Implementation: Interface "MFG IPreflightReactions")
    begin
        IReactions := Implementation;
        IReactionsDefined := true;
    end;
}
