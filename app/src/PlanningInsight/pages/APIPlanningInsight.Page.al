namespace ManufacturingAdvanced.PlanningInsight;

page 85505 "MFG API Planning Insight"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgPlanning';
    APIVersion = 'v1.0';
    EntityName = 'itemPlanningInsight';
    EntitySetName = 'itemPlanningInsights';
    EntityCaption = 'Item planning insight';
    EntitySetCaption = 'Item planning insights';
    SourceTable = "MFG Item Planning Insight";
    Extensible = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(runsWithMessages; Rec."Runs With Messages")
                {
                    Caption = 'Runs with messages';
                }
                field(newRuns; Rec."New Runs")
                {
                    Caption = 'Runs with New';
                }
                field(changeQtyRuns; Rec."Change Qty. Runs")
                {
                    Caption = 'Runs with Change Qty.';
                }
                field(rescheduleRuns; Rec."Reschedule Runs")
                {
                    Caption = 'Runs with Reschedule';
                }
                field(cancelRuns; Rec."Cancel Runs")
                {
                    Caption = 'Runs with Cancel';
                }
                field(advisor; Rec.Advisor)
                {
                    Caption = 'Pattern';
                }
                field(advice; Rec.Advice)
                {
                    Caption = 'Advice';
                }
                field(reorderingPolicy; Rec."Reordering Policy")
                {
                    Caption = 'Reordering policy';
                }
                field(dampenerPeriod; Rec."Dampener Period")
                {
                    Caption = 'Dampener period';
                }
                field(dampenerQuantity; Rec."Dampener Quantity")
                {
                    Caption = 'Dampener quantity';
                }
                field(lotAccumulationPeriod; Rec."Lot Accumulation Period")
                {
                    Caption = 'Lot accumulation period';
                }
                field(reschedulingPeriod; Rec."Rescheduling Period")
                {
                    Caption = 'Rescheduling period';
                }
                field(analyzedAt; Rec."Analyzed At")
                {
                    Caption = 'Analyzed at';
                }
            }
        }
    }
}
