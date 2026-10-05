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
                field("Work Center No."; Rec."Work Center No.")
                {
                    Visible = WorkCenterNo = '';
                }
                field("Capacity Type"; Rec."Capacity Type")
                {
                }
                field("Capacity No."; Rec."Capacity No.")
                {
                }
                field("Previous Operation No."; Rec."Previous Operation No.")
                {
                    Visible = false;
                }
                field("Earliest Start Date"; Rec."Earliest Start Date")
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
                field("Written Back"; Rec."Written Back")
                {
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
            action(CalculateAll)
            {
                Caption = 'Calculate all work centers';
                ToolTip = 'Load every work center at once, so that an operation cannot start before the previous operations of its routing have ended, on whichever work center they are. No production order is changed.';
                Image = CalculateCalendar;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Loading Engine";
                begin
                    WorkCenterNo := '';
                    Message(CalculatedMsg, Engine.CalculateAll());
                    ApplyWorkCenterFilter();
                end;
            }
            action(ApplyPlan)
            {
                Caption = 'Apply to orders';
                ToolTip = 'Move every operation that fits the horizon to its planned starting date on the production order. Business Central reschedules the operations after it and the order line.';
                Image = Approve;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Loading Engine";
                begin
                    if WorkCenterNo = '' then begin
                        if not Confirm(ApplyAllQst, false) then
                            exit;
                    end else
                        if not Confirm(ApplyQst, false, WorkCenterNo) then
                            exit;
                    Message(AppliedMsg, Engine.ApplyPlan(WorkCenterNo));
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
                actionref(CalculateAllRef; CalculateAll)
                {
                }
                actionref(ApplyPlanRef; ApplyPlan)
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
        ApplyQst: Label 'Move the operations of work center %1 that fit the horizon to their planned starting dates on the production orders?', Comment = '%1 = the work center number';
        ApplyAllQst: Label 'Move the operations of every work center that fit the horizon to their planned starting dates on the production orders?';
        AppliedMsg: Label '%1 operation(s) were moved.', Comment = '%1 = the number of operations';

    local procedure ApplyWorkCenterFilter()
    begin
        if WorkCenterNo = '' then
            Rec.SetRange("Work Center No.")
        else
            Rec.SetRange("Work Center No.", WorkCenterNo);
        CurrPage.Update(false);
    end;
}
