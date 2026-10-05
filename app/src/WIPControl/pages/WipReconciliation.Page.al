namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

page 85207 "MFG WIP Reconciliation"
{
    PageType = List;
    ApplicationArea = MFGWIPControl;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "MFG WIP Reconciliation";
    Caption = 'WIP reconciliation';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'WIP account, work in progress, G/L reconciliation, production cost';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Source No."; Rec."Source No.")
                {
                }
                field("Value WIP"; Rec."Value WIP")
                {
                }
                field("G/L WIP"; Rec."G/L WIP")
                {
                }
                field(Difference; Rec.Difference)
                {
                    StyleExpr = StatusStyle;
                }
                field("Unposted Cost"; Rec."Unposted Cost")
                {
                }
                field(Status; Rec.Status)
                {
                    StyleExpr = StatusStyle;
                }
                field("Reconciled At"; Rec."Reconciled At")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reconcile)
            {
                Caption = 'Reconcile';
                ToolTip = 'Compare every released production order, and every order finished in the reconciliation period, with the WIP accounts in the general ledger.';
                Image = Reconcile;

                trigger OnAction()
                var
                    FeatureMgt: Codeunit "MFG Feature Mgt.";
                    Engine: Codeunit "MFG WIP Engine";
                begin
                    FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGWipControl);
                    Message(ReconciledMsg, Engine.Reconcile());
                    CurrPage.Update(false);
                end;
            }
            action(History)
            {
                Caption = 'History';
                ToolTip = 'See earlier reconciliations, order by order and day by day.';
                Image = History;
                RunObject = page "MFG WIP Recon. Entries";
            }
            action(OpenProdOrder)
            {
                Caption = 'Open production order';
                ToolTip = 'Open the production order of the selected line.';
                Image = Document;

                trigger OnAction()
                var
                    ProductionOrder: Record "Production Order";
                begin
                    ProductionOrder.Get(Rec."Prod. Order Status", Rec."Prod. Order No.");
                    if Rec."Prod. Order Status" = Rec."Prod. Order Status"::Finished then
                        Page.Run(Page::"Finished Production Order", ProductionOrder)
                    else
                        Page.Run(Page::"Released Production Order", ProductionOrder);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ReconcileRef; Reconcile)
                {
                }
                actionref(OpenProdOrderRef; OpenProdOrder)
                {
                }
                actionref(HistoryRef; History)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::MFGMatched:
                StatusStyle := 'Favorable';
            Rec.Status::MFGNotPostedYet:
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Unfavorable';
        end;
    end;

    var
        StatusStyle: Text;
        ReconciledMsg: Label '%1 production order(s) reconciled.', Comment = '%1 = the number of production orders';
}
