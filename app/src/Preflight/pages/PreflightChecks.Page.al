namespace ManufacturingAdvanced.Preflight;

page 85101 "MFG Preflight Checks"
{
    PageType = ListPart;
    ApplicationArea = MFGPreflight;
    SourceTable = "MFG Preflight Check";
    Caption = 'Pre-flight checks';
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
