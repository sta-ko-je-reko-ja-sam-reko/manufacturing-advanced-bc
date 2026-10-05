namespace ManufacturingAdvanced.WIPControl;

enum 85202 "MFG Finish Proposal Status"
{
    Caption = 'Finish proposal status';
    Extensible = false;

    value(0; MFGReady)
    {
        Caption = 'Ready';
    }
    value(1; MFGBlocked)
    {
        Caption = 'Blocked';
    }
    value(2; MFGFinished)
    {
        Caption = 'Finished';
    }
    value(3; MFGFailed)
    {
        Caption = 'Failed';
    }
}
