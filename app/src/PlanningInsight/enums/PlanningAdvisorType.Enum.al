namespace ManufacturingAdvanced.PlanningInsight;

enum 85500 "MFG Planning Advisor Type" implements "MFG IPlanningAdvisor"
{
    Caption = 'Planning advisor';
    Extensible = true;
    DefaultImplementation = "MFG IPlanningAdvisor" = "MFG Planning No Advisor";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
    value(1; MFGReschedules)
    {
        Caption = 'Repeated rescheduling';
        Implementation = "MFG IPlanningAdvisor" = "MFG Advise Reschedules";
    }
    value(2; MFGSmallChanges)
    {
        Caption = 'Repeated quantity changes';
        Implementation = "MFG IPlanningAdvisor" = "MFG Advise Quantity Changes";
    }
    value(3; MFGCancelAndNew)
    {
        Caption = 'Cancel and re-create';
        Implementation = "MFG IPlanningAdvisor" = "MFG Advise Cancel And New";
    }
}
