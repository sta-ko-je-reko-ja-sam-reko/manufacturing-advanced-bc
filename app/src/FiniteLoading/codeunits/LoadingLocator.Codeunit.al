namespace ManufacturingAdvanced.FiniteLoading;

codeunit 85704 "MFG Loading Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        ICapacitySource: Interface "MFG ICapacitySource";
        ICapacitySourceDefined: Boolean;

    /// <summary>
    /// Returns the source of daily work center capacity, defaulting to the work center calendar.
    /// </summary>
    /// <returns>The capacity source for this session.</returns>
    procedure CapacitySource(): Interface "MFG ICapacitySource"
    var
        DefaultSource: Codeunit "MFG Calendar Capacity";
    begin
        if not ICapacitySourceDefined then
            Implement(DefaultSource);
        exit(ICapacitySource);
    end;

    /// <summary>
    /// Replaces the capacity source for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure Implement(Implementation: Interface "MFG ICapacitySource")
    begin
        ICapacitySource := Implementation;
        ICapacitySourceDefined := true;
    end;

    /// <summary>
    /// Returns to the default capacity source.
    /// </summary>
    procedure ResetCapacitySource()
    begin
        ICapacitySourceDefined := false;
    end;
}
