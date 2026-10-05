namespace ManufacturingAdvanced.ShopFloor;

enum 85600 "MFG Shop Floor Session Status"
{
    Caption = 'Shop floor session status';
    Extensible = false;

    value(0; MFGRunning)
    {
        Caption = 'Running';
    }
    value(1; MFGStopped)
    {
        Caption = 'Stopped';
    }
}
