namespace ManufacturingAdvanced.EngineeringChange;

page 85801 "MFG ECO List"
{
    PageType = List;
    ApplicationArea = MFGEngineeringChange;
    UsageCategory = Lists;
    SourceTable = "MFG ECO Header";
    Caption = 'Engineering change orders';
    CardPageId = "MFG ECO Card";
    Editable = false;
    AdditionalSearchTerms = 'ECO, engineering change, BOM change, routing change';

    layout
    {
        area(Content)
        {
            repeater(Changes)
            {
                field("No."; Rec."No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Effective Date"; Rec."Effective Date")
                {
                }
                field("Requested By"; Rec."Requested By")
                {
                }
                field("Approved By"; Rec."Approved By")
                {
                }
                field(Lines; Rec.Lines)
                {
                }
            }
        }
    }
}
