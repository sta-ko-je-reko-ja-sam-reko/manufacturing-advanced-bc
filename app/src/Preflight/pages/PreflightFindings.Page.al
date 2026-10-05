namespace ManufacturingAdvanced.Preflight;

page 85102 "MFG Preflight Findings"
{
    PageType = List;
    ApplicationArea = MFGPreflight;
    UsageCategory = Lists;
    SourceTable = "MFG Preflight Finding";
    Caption = 'Pre-flight findings';
    Editable = false;
    SourceTableView = sorting("Prod. Order Status", "Prod. Order No.", Severity) order(descending);

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Severity; Rec.Severity)
                {
                    StyleExpr = SeverityStyle;
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
                field("Component Line No."; Rec."Component Line No.")
                {
                }
                field(Check; Rec.Check)
                {
                }
                field(Message; Rec.Message)
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Checked At"; Rec."Checked At")
                {
                }
                field("Checked By"; Rec."Checked By")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Severity of
            Rec.Severity::MFGError:
                SeverityStyle := 'Unfavorable';
            Rec.Severity::MFGWarning:
                SeverityStyle := 'Ambiguous';
            else
                SeverityStyle := 'Standard';
        end;
    end;

    var
        SeverityStyle: Text;
}
