namespace ManufacturingAdvanced.PlanningInsight;

page 85502 "MFG Planning Runs"
{
    PageType = List;
    ApplicationArea = MFGPlanningInsight;
    UsageCategory = History;
    SourceTable = "MFG Planning Run";
    Caption = 'Recorded planning runs';
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
                field("Worksheet Template Name"; Rec."Worksheet Template Name")
                {
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                }
                field("Recorded At"; Rec."Recorded At")
                {
                }
                field("Recorded By"; Rec."Recorded By")
                {
                }
                field(Messages; Rec.Messages)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowMessages)
            {
                Caption = 'Action messages';
                ToolTip = 'View the action messages of the selected run.';
                Image = Log;
                RunObject = page "MFG Planning Messages";
                RunPageLink = "Run No." = field("Run No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ShowMessagesRef; ShowMessages)
                {
                }
            }
        }
    }
}
