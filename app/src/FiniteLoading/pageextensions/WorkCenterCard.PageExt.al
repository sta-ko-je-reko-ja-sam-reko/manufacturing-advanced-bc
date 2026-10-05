namespace ManufacturingAdvanced.FiniteLoading;

using Microsoft.Manufacturing.WorkCenter;

pageextension 85700 "MFG Work Center Card" extends "Work Center Card"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGLoadPlan)
            {
                ApplicationArea = MFGFiniteLoading;
                AccessByPermission = tabledata "MFG Loading Setup" = R;
                Caption = 'Finite load plan';
                ToolTip = 'See when this work center can really do its open operations, given its calendar capacity.';
                Image = CalculateCalendar;
                RunObject = page "MFG Load Plan";
                RunPageLink = "Work Center No." = field("No.");
            }
        }
    }
}
