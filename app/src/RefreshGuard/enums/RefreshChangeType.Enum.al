namespace ManufacturingAdvanced.RefreshGuard;

enum 85401 "MFG Refresh Change Type"
{
    Caption = 'Refresh change type';
    Extensible = false;

    value(0; MFGChanged)
    {
        Caption = 'Changed';
    }
    value(1; MFGRemoved)
    {
        Caption = 'Removed';
    }
    value(2; MFGAdded)
    {
        Caption = 'Added';
    }
}
