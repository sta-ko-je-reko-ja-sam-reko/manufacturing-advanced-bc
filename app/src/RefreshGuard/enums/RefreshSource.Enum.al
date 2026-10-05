namespace ManufacturingAdvanced.RefreshGuard;

enum 85402 "MFG Refresh Source"
{
    Caption = 'Refresh source';
    Extensible = false;

    value(0; MFGRefreshReport)
    {
        Caption = 'Refresh Production Order';
    }
    value(1; MFGCalculation)
    {
        Caption = 'Recalculation of a line';
    }
}
