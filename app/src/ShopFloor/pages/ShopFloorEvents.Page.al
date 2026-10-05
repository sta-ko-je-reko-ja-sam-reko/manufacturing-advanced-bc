namespace ManufacturingAdvanced.ShopFloor;

page 85605 "MFG Shop Floor Events"
{
    PageType = List;
    ApplicationArea = MFGShopFloor;
    UsageCategory = History;
    SourceTable = "MFG Shop Floor Event";
    Caption = 'Shop floor events';
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Event Type"; Rec."Event Type")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    Visible = false;
                }
                field("Operation No."; Rec."Operation No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                }
                field("Scrap Quantity"; Rec."Scrap Quantity")
                {
                }
                field("Scrap Code"; Rec."Scrap Code")
                {
                }
                field("Run Minutes"; Rec."Run Minutes")
                {
                }
                field("Stop Minutes"; Rec."Stop Minutes")
                {
                }
                field("Stop Code"; Rec."Stop Code")
                {
                }
                field("Reported At"; Rec."Reported At")
                {
                }
                field("Reported By"; Rec."Reported By")
                {
                }
            }
        }
    }
}
