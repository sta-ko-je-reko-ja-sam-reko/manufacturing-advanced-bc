namespace ManufacturingAdvanced.PlanningInsight;

page 85501 "MFG Planning Rules"
{
    PageType = ListPart;
    ApplicationArea = MFGPlanningInsight;
    SourceTable = "MFG Planning Rule";
    Caption = 'Patterns to look for';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Advisor; Rec.Advisor)
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
