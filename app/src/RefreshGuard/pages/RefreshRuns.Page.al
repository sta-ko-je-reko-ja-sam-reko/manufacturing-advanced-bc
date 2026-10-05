namespace ManufacturingAdvanced.RefreshGuard;

page 85401 "MFG Refresh Runs"
{
    PageType = List;
    ApplicationArea = MFGRefreshGuard;
    UsageCategory = History;
    SourceTable = "MFG Refresh Run";
    Caption = 'Production order refreshes';
    Editable = false;
    SourceTableView = sorting("Run No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Run No."; Rec."Run No.")
                {
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Refreshed At"; Rec."Refreshed At")
                {
                }
                field("Refreshed By"; Rec."Refreshed By")
                {
                }
                field(Changes; Rec.Changes)
                {
                }
                field("Open Changes"; Rec."Open Changes")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowChanges)
            {
                Caption = 'Changes';
                ToolTip = 'View what the selected refresh changed, and restore the changes you want back.';
                Image = ChangeLog;
                RunObject = page "MFG Refresh Changes";
                RunPageLink = "Run No." = field("Run No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ShowChangesRef; ShowChanges)
                {
                }
            }
        }
    }
}
