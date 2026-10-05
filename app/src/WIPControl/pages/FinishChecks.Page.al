namespace ManufacturingAdvanced.WIPControl;

page 85201 "MFG Finish Checks"
{
    PageType = ListPart;
    ApplicationArea = MFGWIPControl;
    SourceTable = "MFG Finish Check";
    Caption = 'Checks before finishing';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Check; Rec.Check)
                {
                    Editable = false;
                }
                field(Severity; Rec.Severity)
                {
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
            }
        }
    }
}
