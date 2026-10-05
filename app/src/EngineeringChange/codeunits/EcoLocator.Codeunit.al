namespace ManufacturingAdvanced.EngineeringChange;

codeunit 85813 "MFG ECO Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IOrderRefresh: Interface "MFG IEcoOrderRefresh";
        IOrderRefreshDefined: Boolean;

    /// <summary>
    /// Returns the implementation that refreshes the orders an implemented change impacts, defaulting to the
    /// standard Refresh Production Order.
    /// </summary>
    /// <returns>The order refresh for this session.</returns>
    procedure OrderRefresh(): Interface "MFG IEcoOrderRefresh"
    var
        DefaultOrderRefresh: Codeunit "MFG ECO Report Refresh";
    begin
        if not IOrderRefreshDefined then
            ImplementOrderRefresh(DefaultOrderRefresh);
        exit(IOrderRefresh);
    end;

    /// <summary>
    /// Replaces the order refresh for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure ImplementOrderRefresh(Implementation: Interface "MFG IEcoOrderRefresh")
    begin
        IOrderRefresh := Implementation;
        IOrderRefreshDefined := true;
    end;

    /// <summary>
    /// Returns to the default order refresh.
    /// </summary>
    procedure ResetOrderRefresh()
    begin
        IOrderRefreshDefined := false;
    end;
}
