namespace ManufacturingAdvanced.RefreshGuard;

page 85402 "MFG Refresh Changes"
{
    PageType = List;
    ApplicationArea = MFGRefreshGuard;
    UsageCategory = None;
    SourceTable = "MFG Refresh Change";
    Caption = 'Refresh changes';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Run No."; Rec."Run No.")
                {
                    Visible = false;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field(Kind; Rec.Kind)
                {
                }
                field("Change Type"; Rec."Change Type")
                {
                }
                field(Subject; Rec.Subject)
                {
                }
                field("Field Caption"; Rec."Field Caption")
                {
                }
                field("Old Value"; Rec."Old Value")
                {
                    StyleExpr = OldValueStyle;
                }
                field("New Value"; Rec."New Value")
                {
                }
                field(Restorable; Rec.Restorable)
                {
                }
                field(Restored; Rec.Restored)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestoreSelected)
            {
                Caption = 'Restore';
                ToolTip = 'Put back what the refresh changed, for the selected lines that can be restored: the value from before the refresh, a component the refresh removed, or the removal of a component the refresh added.';
                Image = Restore;

                trigger OnAction()
                var
                    Change: Record "MFG Refresh Change";
                    Engine: Codeunit "MFG Refresh Engine";
                begin
                    CurrPage.SetSelectionFilter(Change);
                    Message(RestoredMsg, Engine.RestoreAll(Change));
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(RestoreSelectedRef; RestoreSelected)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Restorable and not Rec.Restored then
            OldValueStyle := 'StrongAccent'
        else
            OldValueStyle := 'Standard';
    end;

    var
        OldValueStyle: Text;
        RestoredMsg: Label '%1 change(s) restored.', Comment = '%1 = the number of changes restored';
}
