namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Manufacturing.StandardCost;

page 85302 "MFG Cost Drift"
{
    PageType = List;
    ApplicationArea = MFGCostDrift;
    UsageCategory = Tasks;
    SourceTable = "MFG Cost Drift Line";
    Caption = 'Standard cost drift';
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Item No.");
    AdditionalSearchTerms = 'stale standard cost, roll up, purchase price';

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
                field("Item No."; Rec."Item No.")
                {
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
                field(Source; Rec.Source)
                {
                    Editable = false;
                }
                field("Current Standard Cost"; Rec."Current Standard Cost")
                {
                    Editable = false;
                }
                field("Proposed Standard Cost"; Rec."Proposed Standard Cost")
                {
                    Editable = false;
                }
                field("Drift Amount"; Rec."Drift Amount")
                {
                    Editable = false;
                    StyleExpr = DriftStyle;
                }
                field("Drift %"; Rec."Drift %")
                {
                    Editable = false;
                    StyleExpr = DriftStyle;
                }
                field("Last Unit Cost Calc. Date"; Rec."Last Unit Cost Calc. Date")
                {
                    Editable = false;
                }
                field("Replenishment System"; Rec."Replenishment System")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Transferred; Rec.Transferred)
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Calculate)
            {
                Caption = 'Calculate';
                ToolTip = 'Compare every standard-cost item''s standard cost with what each active source proposes today, and list those beyond the tolerance.';
                Image = CalculateCost;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Cost Drift Engine";
                begin
                    Message(CalculatedMsg, Engine.Calculate());
                end;
            }
            action(SendToWorksheet)
            {
                Caption = 'Send to worksheet';
                ToolTip = 'Send the selected lines to the standard cost worksheet, where you review them and implement them with Implement Standard Cost Changes. Nothing changes on the items until then.';
                Image = SuggestLines;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Cost Drift Engine";
                begin
                    Message(SentMsg, Engine.TransferSelected(), Engine.EnsureWorksheet());
                end;
            }
            action(OpenWorksheet)
            {
                Caption = 'Standard cost worksheet';
                ToolTip = 'Open the standard cost worksheet the drift lines are sent to.';
                Image = Worksheet;

                trigger OnAction()
                var
                    StandardCostWorksheet: Record "Standard Cost Worksheet";
                    Engine: Codeunit "MFG Cost Drift Engine";
                begin
                    StandardCostWorksheet.SetRange("Standard Cost Worksheet Name", Engine.EnsureWorksheet());
                    Page.Run(Page::"Standard Cost Worksheet", StandardCostWorksheet);
                end;
            }
            action(OrderVariances)
            {
                Caption = 'Order variances';
                ToolTip = 'View the variances of recently finished production orders by type.';
                Image = CostAccounting;
                RunObject = page "MFG Order Variances";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CalculateRef; Calculate)
                {
                }
                actionref(SendToWorksheetRef; SendToWorksheet)
                {
                }
                actionref(OpenWorksheetRef; OpenWorksheet)
                {
                }
                actionref(OrderVariancesRef; OrderVariances)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SelectEditable := not Rec.Transferred;
        if Rec."Drift Amount" > 0 then
            DriftStyle := 'Unfavorable'
        else
            DriftStyle := 'Favorable';
    end;

    var
        DriftStyle: Text;
        SelectEditable: Boolean;
        CalculatedMsg: Label '%1 item(s) have a standard cost beyond the tolerance.', Comment = '%1 = the number of items';
        SentMsg: Label '%1 line(s) were sent to standard cost worksheet %2.', Comment = '%1 = the number of lines, %2 = the worksheet name';
}
