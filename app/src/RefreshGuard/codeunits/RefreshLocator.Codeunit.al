namespace ManufacturingAdvanced.RefreshGuard;

codeunit 85404 "MFG Refresh Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IReactions: Interface "MFG IRefreshReactions";
        IReactionsDefined: Boolean;

    /// <summary>
    /// Returns the implementation that reacts to a refresh, defaulting to the built-in one.
    /// </summary>
    /// <returns>The reactions implementation for this session.</returns>
    procedure Reactions(): Interface "MFG IRefreshReactions"
    var
        DefaultReactions: Codeunit "MFG Refresh Reactions";
    begin
        if not IReactionsDefined then
            Implement(DefaultReactions);
        exit(IReactions);
    end;

    /// <summary>
    /// Replaces the reactions implementation for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure Implement(Implementation: Interface "MFG IRefreshReactions")
    begin
        IReactions := Implementation;
        IReactionsDefined := true;
    end;
}
