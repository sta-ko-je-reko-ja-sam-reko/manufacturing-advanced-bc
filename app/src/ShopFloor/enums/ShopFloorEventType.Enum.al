namespace ManufacturingAdvanced.ShopFloor;

enum 85601 "MFG Shop Floor Event Type"
{
    Caption = 'Shop floor event type';
    Extensible = false;

    value(0; MFGOutput)
    {
        Caption = 'Output';
    }
    value(1; MFGDowntime)
    {
        Caption = 'Downtime';
    }
}
