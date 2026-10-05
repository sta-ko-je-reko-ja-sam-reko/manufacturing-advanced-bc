namespace ManufacturingAdvanced.WIPControl;

enum 85200 "MFG Finish Check Type" implements "MFG IFinishCheck"
{
    Caption = 'Finish check';
    Extensible = true;
    DefaultImplementation = "MFG IFinishCheck" = "MFG Finish No Check";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
    value(1; MFGMissingConsumption)
    {
        Caption = 'Consumption still missing';
        Implementation = "MFG IFinishCheck" = "MFG Check Missing Consumption";
    }
    value(2; MFGOpenWhseActivity)
    {
        Caption = 'Open warehouse picks';
        Implementation = "MFG IFinishCheck" = "MFG Check Open Whse. Activity";
    }
    value(3; MFGUnfinishedOperations)
    {
        Caption = 'Operations not finished';
        Implementation = "MFG IFinishCheck" = "MFG Check Unfinished Ops.";
    }
}
