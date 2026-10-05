namespace ManufacturingAdvanced.Preflight;

enum 85101 "MFG Preflight Severity"
{
    Caption = 'Pre-flight severity';
    Extensible = false;

    value(0; MFGOff)
    {
        Caption = 'Off';
    }
    value(1; MFGWarning)
    {
        Caption = 'Warning';
    }
    value(2; MFGError)
    {
        Caption = 'Error';
    }
}
