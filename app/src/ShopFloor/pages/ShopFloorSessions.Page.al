namespace ManufacturingAdvanced.ShopFloor;

page 85604 "MFG Shop Floor Sessions"
{
    PageType = List;
    ApplicationArea = MFGShopFloor;
    UsageCategory = History;
    SourceTable = "MFG Shop Floor Session";
    Caption = 'Shop floor sessions';
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
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Operation No."; Rec."Operation No.")
                {
                }
                field("Work Center No."; Rec."Work Center No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field(Operator; Rec.Operator)
                {
                }
                field("Started At"; Rec."Started At")
                {
                }
                field("Stopped At"; Rec."Stopped At")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Minutes; Rec.Minutes)
                {
                }
                field("Run Time Posted"; Rec."Run Time Posted")
                {
                }
            }
        }
    }
}
