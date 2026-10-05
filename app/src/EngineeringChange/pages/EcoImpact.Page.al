namespace ManufacturingAdvanced.EngineeringChange;

page 85804 "MFG ECO Impact"
{
    PageType = List;
    ApplicationArea = MFGEngineeringChange;
    UsageCategory = None;
    SourceTable = "MFG ECO Impact";
    Caption = 'Engineering change impact';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Object Type"; Rec."Object Type")
                {
                }
                field("Object No."; Rec."Object No.")
                {
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                field("Version In Use"; Rec."Version In Use")
                {
                }
            }
        }
    }
}
