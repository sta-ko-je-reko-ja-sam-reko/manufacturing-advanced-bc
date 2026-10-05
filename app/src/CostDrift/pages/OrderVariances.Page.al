namespace ManufacturingAdvanced.CostDrift;

page 85303 "MFG Order Variances"
{
    PageType = List;
    ApplicationArea = MFGCostDrift;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "MFG Order Variance";
    Caption = 'Production order variances';
    Editable = false;
    AdditionalSearchTerms = 'material variance, capacity variance, overhead variance';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Finished Date"; Rec."Finished Date")
                {
                }
                field("Output Cost"; Rec."Output Cost")
                {
                }
                field("Material Variance"; Rec."Material Variance")
                {
                }
                field("Capacity Variance"; Rec."Capacity Variance")
                {
                }
                field("Cap. Overhead Variance"; Rec."Cap. Overhead Variance")
                {
                }
                field("Mfg. Overhead Variance"; Rec."Mfg. Overhead Variance")
                {
                }
                field("Subcontracted Variance"; Rec."Subcontracted Variance")
                {
                }
                field("Total Variance"; Rec."Total Variance")
                {
                    StyleExpr = TotalStyle;
                }
                field("Variance %"; Rec."Variance %")
                {
                    StyleExpr = TotalStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateVariances)
            {
                Caption = 'Calculate';
                ToolTip = 'List the production orders finished within the variance period with their variances by type. Variances exist only after costs have been adjusted.';
                Image = CalculateCost;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Cost Drift Engine";
                begin
                    Message(CalculatedMsg, Engine.CalculateVariances());
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CalculateVariancesRef; CalculateVariances)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Total Variance" > 0 then
            TotalStyle := 'Unfavorable'
        else
            TotalStyle := 'Favorable';
    end;

    var
        TotalStyle: Text;
        CalculatedMsg: Label '%1 finished production order(s) listed.', Comment = '%1 = the number of orders';
}
