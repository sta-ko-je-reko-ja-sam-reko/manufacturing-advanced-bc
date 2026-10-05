namespace ManufacturingAdvanced.WIPControl;

codeunit 85207 "MFG WIP Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IValuation: Interface "MFG IWipValuation";
        IValuationDefined: Boolean;

    /// <summary>
    /// Returns the implementation that values an order's work in progress, defaulting to the one that
    /// reads value entries.
    /// </summary>
    /// <returns>The valuation implementation for this session.</returns>
    procedure Valuation(): Interface "MFG IWipValuation"
    var
        DefaultValuation: Codeunit "MFG WIP Value Entries";
    begin
        if not IValuationDefined then
            Implement(DefaultValuation);
        exit(IValuation);
    end;

    /// <summary>
    /// Replaces the valuation for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure Implement(Implementation: Interface "MFG IWipValuation")
    begin
        IValuation := Implementation;
        IValuationDefined := true;
    end;

    /// <summary>
    /// Returns to the default valuation.
    /// </summary>
    procedure ResetValuation()
    begin
        IValuationDefined := false;
    end;
}
