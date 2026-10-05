namespace ManufacturingAdvanced.EngineeringChange;

page 85803 "MFG ECO Subform"
{
    PageType = ListPart;
    ApplicationArea = MFGEngineeringChange;
    SourceTable = "MFG ECO Line";
    Caption = 'Lines';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Object Type"; Rec."Object Type")
                {
                }
                field("No."; Rec."No.")
                {
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
                field("Change Description"; Rec."Change Description")
                {
                }
                field("New Version Code"; Rec."New Version Code")
                {

                    trigger OnDrillDown()
                    var
                        EcoObject: Interface "MFG IEcoObject";
                    begin
                        EcoObject := Rec."Object Type";
                        EcoObject.OpenVersion(Rec);
                    end;
                }
            }
        }
    }
}
