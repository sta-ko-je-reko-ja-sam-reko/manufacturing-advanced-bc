namespace ManufacturingAdvanced.Core;

enum 85001 "MFG Setup Step Status"
{
    Caption = 'Manufacturing advanced setup step status';
    Extensible = false;

    value(0; MFGNotStarted)
    {
        Caption = 'Not started';
    }
    value(1; MFGInProgress)
    {
        Caption = 'In progress';
    }
    value(2; MFGCompleted)
    {
        Caption = 'Completed';
    }
}
