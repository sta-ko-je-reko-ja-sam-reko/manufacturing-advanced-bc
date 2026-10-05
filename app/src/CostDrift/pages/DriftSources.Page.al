namespace ManufacturingAdvanced.CostDrift;

page 85301 "MFG Drift Sources"
{
    PageType = ListPart;
    ApplicationArea = MFGCostDrift;
    SourceTable = "MFG Drift Source";
    Caption = 'Compare standard cost with';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Source; Rec.Source)
                {
                    Editable = false;
                }
                field(Active; Rec.Active)
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
