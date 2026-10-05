namespace ManufacturingAdvanced.WIPControl;

codeunit 85207 "MFG WIP Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IValuation: Interface "MFG IWipValuation";
        IValuationDefined: Boolean;
        IGLSource: Interface "MFG IGLWipSource";
        IGLSourceDefined: Boolean;

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

    /// <summary>
    /// Returns the implementation that reads an order's WIP from the general ledger, defaulting to the one that
    /// follows the G/L - Item Ledger Relation to the WIP accounts.
    /// </summary>
    /// <returns>The G/L source for this session.</returns>
    procedure GLSource(): Interface "MFG IGLWipSource"
    var
        DefaultGLSource: Codeunit "MFG WIP GL Source";
    begin
        if not IGLSourceDefined then
            ImplementGLSource(DefaultGLSource);
        exit(IGLSource);
    end;

    /// <summary>
    /// Replaces the G/L source for the rest of the session, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure ImplementGLSource(Implementation: Interface "MFG IGLWipSource")
    begin
        IGLSource := Implementation;
        IGLSourceDefined := true;
    end;

    /// <summary>
    /// Returns to the default G/L source.
    /// </summary>
    procedure ResetGLSource()
    begin
        IGLSourceDefined := false;
    end;
}
