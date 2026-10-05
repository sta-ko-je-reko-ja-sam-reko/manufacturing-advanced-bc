namespace ManufacturingAdvanced.PlanningInsight;

using Microsoft.Inventory.Requisition;

pageextension 85500 "MFG Planning Worksheet" extends "Planning Worksheet"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGRecordMessages)
            {
                ApplicationArea = MFGPlanningInsight;
                AccessByPermission = tabledata "MFG Planning Setup" = R;
                Caption = 'Record action messages';
                ToolTip = 'Record the action messages now on this worksheet batch as a planning run, so the planning insight can learn from them.';
                Image = Log;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Planning Engine";
                begin
                    if Engine.RecordRun(Rec."Worksheet Template Name", Rec."Journal Batch Name") = 0 then
                        Message(NothingRecordedMsg)
                    else
                        Message(RecordedMsg);
                end;
            }
            action(MFGPlanningInsight)
            {
                ApplicationArea = MFGPlanningInsight;
                AccessByPermission = tabledata "MFG Planning Setup" = R;
                Caption = 'Planning insight';
                ToolTip = 'See which items planning keeps rescheduling, changing or cancelling, and which planning parameter to adjust.';
                Image = Forecast;
                RunObject = page "MFG Item Planning Insights";
            }
        }
    }

    var
        NothingRecordedMsg: Label 'There are no action messages on this worksheet batch to record.';
        RecordedMsg: Label 'The action messages of this worksheet batch were recorded.';
}
