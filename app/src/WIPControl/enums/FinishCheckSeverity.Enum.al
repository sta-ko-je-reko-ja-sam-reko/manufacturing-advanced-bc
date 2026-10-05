namespace ManufacturingAdvanced.WIPControl;

enum 85201 "MFG Finish Check Severity"
{
    Caption = 'Finish check severity';
    Extensible = false;

    value(0; MFGOff)
    {
        Caption = 'Off';
    }
    value(1; MFGInform)
    {
        Caption = 'Inform';
    }
    value(2; MFGBlock)
    {
        Caption = 'Block';
    }
}
