namespace ManufacturingAdvanced.ShopFloor;

codeunit 85604 "MFG Shop Floor Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IPosting: Interface "MFG IShopFloorPosting";
        IPostingDefined: Boolean;

    /// <summary>
    /// Returns the implementation that posts what operators report, defaulting to the one that posts through
    /// the standard item journal posting.
    /// </summary>
    /// <returns>The posting implementation for this session.</returns>
    procedure Posting(): Interface "MFG IShopFloorPosting"
    var
        DefaultPosting: Codeunit "MFG Shop Floor Journal Posting";
    begin
        if not IPostingDefined then
            Implement(DefaultPosting);
        exit(IPosting);
    end;

    /// <summary>
    /// Replaces the posting implementation for the rest of the session, for tests and dependent apps, for
    /// example one that posts through an MES.
    /// </summary>
    /// <param name="Implementation">The implementation to use.</param>
    procedure Implement(Implementation: Interface "MFG IShopFloorPosting")
    begin
        IPosting := Implementation;
        IPostingDefined := true;
    end;

    /// <summary>
    /// Returns to the default posting.
    /// </summary>
    procedure ResetPosting()
    begin
        IPostingDefined := false;
    end;
}
