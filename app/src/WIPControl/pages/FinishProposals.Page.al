namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

page 85202 "MFG Finish Proposals"
{
    PageType = List;
    ApplicationArea = MFGWIPControl;
    UsageCategory = Tasks;
    SourceTable = "MFG Finish Proposal";
    Caption = 'Finish proposals';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'WIP control, work in progress, unfinished production orders';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Selected; Rec.Selected)
                {
                    Editable = SelectEditable;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    StyleExpr = StatusStyle;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        OpenOrder();
                    end;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
                field("Source No."; Rec."Source No.")
                {
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                }
                field("Finished Quantity"; Rec."Finished Quantity")
                {
                    Editable = false;
                }
                field("Last Output Date"; Rec."Last Output Date")
                {
                    Editable = false;
                }
                field("Days Since Output"; Rec."Days Since Output")
                {
                    Editable = false;
                }
                field("Est. WIP Amount"; Rec."Est. WIP Amount")
                {
                    Editable = false;
                }
                field("Consumption Cost"; Rec."Consumption Cost")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Capacity Cost"; Rec."Capacity Cost")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Output Cost"; Rec."Output Cost")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Notes; Rec.Notes)
                {
                    Editable = false;
                }
                field("Suggested At"; Rec."Suggested At")
                {
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Suggest)
            {
                Caption = 'Suggest';
                ToolTip = 'Find every released production order whose output is complete, value the work in progress it still holds, and run the checks before finishing.';
                Image = SuggestLines;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG WIP Engine";
                begin
                    Message(SuggestedMsg, Engine.Suggest());
                end;
            }
            action(SelectReady)
            {
                Caption = 'Select all ready';
                ToolTip = 'Select every proposal with status Ready, so that Finish selected finishes them.';
                Image = SelectEntries;

                trigger OnAction()
                begin
                    SelectAllReady();
                end;
            }
            action(FinishSelected)
            {
                Caption = 'Finish selected';
                ToolTip = 'Finish the selected production orders that are ready, through the standard status change. An order that fails is marked Failed with the reason, and the others go ahead.';
                Image = ReleaseDoc;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG WIP Engine";
                begin
                    if not Confirm(FinishQst, false) then
                        exit;
                    Message(FinishedMsg, Engine.FinishSelected());
                end;
            }
            action(WipReconciliation)
            {
                Caption = 'WIP reconciliation';
                ToolTip = 'Compare, order by order, the work in progress in the value entries with what the general ledger holds on the WIP accounts.';
                Image = Reconcile;
                RunObject = page "MFG WIP Reconciliation";
            }
            action(OpenProdOrder)
            {
                Caption = 'Open production order';
                ToolTip = 'Open the released production order of the selected proposal.';
                Image = Document;

                trigger OnAction()
                begin
                    OpenOrder();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SuggestRef; Suggest)
                {
                }
                actionref(SelectReadyRef; SelectReady)
                {
                }
                actionref(FinishSelectedRef; FinishSelected)
                {
                }
                actionref(OpenProdOrderRef; OpenProdOrder)
                {
                }
                actionref(WipReconciliationRef; WipReconciliation)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SelectEditable := Rec.Status = Rec.Status::MFGReady;
        case Rec.Status of
            Rec.Status::MFGBlocked, Rec.Status::MFGFailed:
                StatusStyle := 'Unfavorable';
            Rec.Status::MFGFinished:
                StatusStyle := 'Favorable';
            else
                StatusStyle := 'Standard';
        end;
    end;

    var
        StatusStyle: Text;
        SelectEditable: Boolean;
        SuggestedMsg: Label '%1 production order(s) have complete output and are proposed for finishing.', Comment = '%1 = the number of proposals';
        FinishQst: Label 'Finish the selected production orders that are ready? Their status changes to Finished and their costs settle at the next cost adjustment.';
        FinishedMsg: Label '%1 production order(s) were finished. Orders that failed are marked Failed with the reason.', Comment = '%1 = the number of orders finished';

    local procedure SelectAllReady()
    var
        Proposal: Record "MFG Finish Proposal";
    begin
        Proposal.SetRange(Status, Proposal.Status::MFGReady);
        Proposal.ModifyAll(Selected, true, true);
        CurrPage.Update(false);
    end;

    local procedure OpenOrder()
    var
        ProductionOrder: Record "Production Order";
    begin
        if not ProductionOrder.Get(ProductionOrder.Status::Released, Rec."Prod. Order No.") then
            exit;
        Page.Run(Page::"Released Production Order", ProductionOrder);
    end;
}
