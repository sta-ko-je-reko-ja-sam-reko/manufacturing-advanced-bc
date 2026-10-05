namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

pageextension 85200 "MFG Released Prod. Orders" extends "Released Production Orders"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGFinishProposals)
            {
                ApplicationArea = MFGWIPControl;
                AccessByPermission = tabledata "MFG WIP Setup" = R;
                Caption = 'Finish proposals';
                ToolTip = 'Find the released production orders whose output is complete but that were never finished, see the work in progress they still hold, and finish the ones that are ready.';
                Image = SuggestLines;
                RunObject = page "MFG Finish Proposals";
            }
        }
    }
}
