namespace ManufacturingAdvanced.PlanningInsight;

page 85503 "MFG Planning Messages"
{
    PageType = List;
    ApplicationArea = MFGPlanningInsight;
    UsageCategory = None;
    SourceTable = "MFG Planning Message";
    Caption = 'Recorded action messages';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Run No."; Rec."Run No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Action Message"; Rec."Action Message")
                {
                }
                field("Original Due Date"; Rec."Original Due Date")
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                field("Original Quantity"; Rec."Original Quantity")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Ref. Order Type"; Rec."Ref. Order Type")
                {
                }
                field("Ref. Order No."; Rec."Ref. Order No.")
                {
                }
            }
        }
    }
}
