namespace ManufacturingAdvanced.PlanningInsight;

using Microsoft.Inventory.Item;

page 85504 "MFG Item Planning Insights"
{
    PageType = List;
    ApplicationArea = MFGPlanningInsight;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "MFG Item Planning Insight";
    Caption = 'Planning insight';
    Editable = false;
    AdditionalSearchTerms = 'action message churn, nervous planning, dampener';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Runs With Messages"; Rec."Runs With Messages")
                {
                }
                field("Reschedule Runs"; Rec."Reschedule Runs")
                {
                }
                field("Change Qty. Runs"; Rec."Change Qty. Runs")
                {
                }
                field("Cancel Runs"; Rec."Cancel Runs")
                {
                }
                field("New Runs"; Rec."New Runs")
                {
                }
                field(Advisor; Rec.Advisor)
                {
                }
                field(Advice; Rec.Advice)
                {
                    StyleExpr = AdviceStyle;
                }
                field("Reordering Policy"; Rec."Reordering Policy")
                {
                }
                field("Dampener Period"; Rec."Dampener Period")
                {
                }
                field("Dampener Quantity"; Rec."Dampener Quantity")
                {
                }
                field("Lot Accumulation Period"; Rec."Lot Accumulation Period")
                {
                    Visible = false;
                }
                field("Rescheduling Period"; Rec."Rescheduling Period")
                {
                    Visible = false;
                }
                field("Analyzed At"; Rec."Analyzed At")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Analyze)
            {
                Caption = 'Analyze';
                ToolTip = 'Count, per item, how often recorded planning runs rescheduled, changed, cancelled or created its orders, and give advice where a pattern repeats.';
                Image = Calculate;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Planning Engine";
                begin
                    Message(AnalyzedMsg, Engine.Analyze());
                end;
            }
            action(ItemCard)
            {
                Caption = 'Item card';
                ToolTip = 'Open the item card to adjust its planning parameters.';
                Image = Item;
                RunObject = page "Item Card";
                RunPageLink = "No." = field("Item No.");
            }
            action(Runs)
            {
                Caption = 'Recorded runs';
                ToolTip = 'View the planning runs that were recorded.';
                Image = History;
                RunObject = page "MFG Planning Runs";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(AnalyzeRef; Analyze)
                {
                }
                actionref(ItemCardRef; ItemCard)
                {
                }
                actionref(RunsRef; Runs)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Advice <> '' then
            AdviceStyle := 'Attention'
        else
            AdviceStyle := 'Standard';
    end;

    var
        AdviceStyle: Text;
        AnalyzedMsg: Label '%1 item(s) got action messages in the recorded runs.', Comment = '%1 = the number of items';
}
