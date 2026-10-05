namespace ManufacturingAdvanced.Preflight;

enum 85100 "MFG Preflight Check Type" implements "MFG IPreflightCheck"
{
    Caption = 'Pre-flight check';
    Extensible = true;
    DefaultImplementation = "MFG IPreflightCheck" = "MFG Preflight No Check";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
    value(1; MFGRoutingLink)
    {
        Caption = 'Routing link without operation';
        Implementation = "MFG IPreflightCheck" = "MFG Check Routing Link";
    }
    value(2; MFGFlushingTracking)
    {
        Caption = 'Automatic flushing without item tracking';
        Implementation = "MFG IPreflightCheck" = "MFG Check Flushing Tracking";
    }
    value(3; MFGMissingBin)
    {
        Caption = 'Missing bin';
        Implementation = "MFG IPreflightCheck" = "MFG Check Missing Bin";
    }
    value(4; MFGUncertifiedDesign)
    {
        Caption = 'BOM or routing not certified';
        Implementation = "MFG IPreflightCheck" = "MFG Check Uncertified Design";
    }
}
