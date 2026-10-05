namespace ManufacturingAdvanced.WIPControl;

enum 85203 "MFG WIP Recon. Status"
{
    Caption = 'WIP reconciliation status';
    Extensible = false;

    value(0; MFGMatched)
    {
        Caption = 'Matched';
    }
    value(1; MFGNotPostedYet)
    {
        Caption = 'Not posted to G/L yet';
    }
    value(2; MFGInvestigate)
    {
        Caption = 'Investigate';
    }
}
