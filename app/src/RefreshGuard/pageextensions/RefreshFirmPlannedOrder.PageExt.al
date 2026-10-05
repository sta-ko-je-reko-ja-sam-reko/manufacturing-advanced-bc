namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

pageextension 85400 "MFG Refresh Firm Planned Order" extends "Firm Planned Prod. Order"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGRefreshRuns)
            {
                ApplicationArea = MFGRefreshGuard;
                AccessByPermission = tabledata "MFG Refresh Setup" = R;
                Caption = 'Refresh changes';
                ToolTip = 'View what each refresh of this production order changed in its components and operations, and restore what you want back.';
                Image = ChangeLog;
                RunObject = page "MFG Refresh Runs";
                RunPageLink = "Prod. Order Status" = field(Status), "Prod. Order No." = field("No.");
            }
        }
    }
}
