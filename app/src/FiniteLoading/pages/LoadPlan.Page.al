namespace ManufacturingAdvanced.FiniteLoading;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;

page 85701 "MFG Load Plan"
{
    PageType = Worksheet;
    ApplicationArea = MFGFiniteLoading;
    UsageCategory = Tasks;
    SourceTable = "MFG Load Plan Line";
    SourceTableView = sorting("Work Center No.", "Sequence No.");
    Caption = 'Finite load plan';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    AdditionalSearchTerms = 'finite capacity, work center schedule, late operations';

    layout
    {
        area(Content)
        {
            group(WorkCenter)
            {
                Caption = 'Work center';

                field(WorkCenterFilter; WorkCenterNo)
                {
                    Caption = 'Work center';
                    ToolTip = 'Specifies the work center whose load plan is shown and calculated.';
                    TableRelation = "Work Center";

                    trigger OnValidate()
                    begin
                        ApplyWorkCenterFilter();
                    end;
                }
            }
            repeater(Operations)
            {
                field("Sequence No."; Rec."Sequence No.")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Operation No."; Rec."Operation No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Need; Rec.Need)
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                field("Current Starting Date"; Rec."Current Starting Date")
                {
                }
                field("Current Ending Date"; Rec."Current Ending Date")
                {
                }
                field("Planned Starting Date"; Rec."Planned Starting Date")
                {
                    StyleExpr = LateStyle;
                }
                field("Planned Ending Date"; Rec."Planned Ending Date")
                {
                    StyleExpr = LateStyle;
                }
                field("Fits Horizon"; Rec."Fits Horizon")
                {
                }
                field(Late; Rec.Late)
                {
                    StyleExpr = LateStyle;
                }
                field("Days Late"; Rec."Days Late")
                {
                    StyleExpr = LateStyle;
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
                ToolTip = 'Sequence the work center''s open operations and load them day by day onto its capacity. No production order is changed.';
                Image = CalculateCalendar;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Loading Engine";
                begin
                    if WorkCenterNo = '' then
                        Error(ChooseWorkCenterErr);
                    Message(CalculatedMsg, Engine.Calculate(WorkCenterNo));
                    CurrPage.Update(false);
                end;
            }
            action(OpenOrder)
            {
                Caption = 'Production order';
                ToolTip = 'Open the production order of the selected operation.';
                Image = Document;

                trigger OnAction()
                var
                    ProductionOrder: Record "Production Order";
                begin
                    if not ProductionOrder.Get(Rec."Prod. Order Status", Rec."Prod. Order No.") then
                        exit;
                    case ProductionOrder.Status of
                        ProductionOrder.Status::Released:
                            Page.Run(Page::"Released Production Order", ProductionOrder);
                        else
                            Page.Run(Page::"Firm Planned Prod. Order", ProductionOrder);
                    end;
                end;
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
                actionref(OpenOrderRef; OpenOrder)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        WorkCenterNo := CopyStr(Rec.GetFilter("Work Center No."), 1, MaxStrLen(WorkCenterNo));
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Late then
            LateStyle := 'Unfavorable'
        else
            LateStyle := 'Standard';
    end;

    var
        WorkCenterNo: Code[20];
        LateStyle: Text;
        ChooseWorkCenterErr: Label 'Choose a work center first.';
        CalculatedMsg: Label '%1 open operation(s) were loaded.', Comment = '%1 = the number of operations';

    local procedure ApplyWorkCenterFilter()
    begin
        if WorkCenterNo = '' then
            Rec.SetRange("Work Center No.")
        else
            Rec.SetRange("Work Center No.", WorkCenterNo);
        CurrPage.Update(false);
    end;
}
