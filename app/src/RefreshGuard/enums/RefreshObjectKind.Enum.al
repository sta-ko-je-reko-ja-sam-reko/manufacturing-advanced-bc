namespace ManufacturingAdvanced.RefreshGuard;

enum 85400 "MFG Refresh Object Kind" implements "MFG IRefreshObject"
{
    Caption = 'Refresh object kind';
    Extensible = true;
    DefaultImplementation = "MFG IRefreshObject" = "MFG Refresh No Object";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
    value(1; MFGComponent)
    {
        Caption = 'Component';
        Implementation = "MFG IRefreshObject" = "MFG Refresh Components";
    }
    value(2; MFGOperation)
    {
        Caption = 'Operation';
        Implementation = "MFG IRefreshObject" = "MFG Refresh Operations";
    }
}
