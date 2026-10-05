namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;

page 85601 "MFG Shop Floor Terminal"
{
    PageType = Worksheet;
    ApplicationArea = MFGShopFloor;
    UsageCategory = Tasks;
    SourceTable = "Prod. Order Routing Line";
    SourceTableView = sorting(Status, "Prod. Order No.", "Routing Reference No.", "Routing No.", "Operation No.") where(Status = const(Released), "Routing Status" = filter(<> Finished));
    Caption = 'Shop floor terminal';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    AdditionalSearchTerms = 'operator terminal, report output, report scrap, downtime';

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
                    ToolTip = 'Specifies the work center whose open operations are shown. Leave it empty to see every work center.';
                    TableRelation = "Work Center";

                    trigger OnValidate()
                    begin
                        ApplyWorkCenterFilter();
                    end;
                }
            }
            repeater(Operations)
            {
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    Editable = false;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    Editable = false;
                }
                field("Routing Status"; Rec."Routing Status")
                {
                    Editable = false;
                }
                field(Running; Running)
                {
                    Caption = 'Running';
                    ToolTip = 'Specifies whether you have this operation running.';
                    Editable = false;
                    StyleExpr = RunningStyle;
                }
                field("Starting Date-Time"; Rec."Starting Date-Time")
                {
                    Editable = false;
                }
                field("Ending Date-Time"; Rec."Ending Date-Time")
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
            action(Start)
            {
                Caption = 'Start';
                ToolTip = 'Start the clock on the selected operation.';
                Image = Start;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Shop Floor Engine";
                begin
                    Engine.StartOperation(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Stop)
            {
                Caption = 'Stop';
                ToolTip = 'Stop the clock on the selected operation.';
                Image = Stop;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Shop Floor Engine";
                begin
                    Message(StoppedMsg, Engine.StopOperation(Rec));
                    CurrPage.Update(false);
                end;
            }
            action(ReportOutput)
            {
                Caption = 'Report output';
                ToolTip = 'Report the good and scrapped quantity of the selected operation. It is posted straight away.';
                Image = OutputJournal;

                trigger OnAction()
                var
                    OutputDialog: Page "MFG Output Dialog";
                begin
                    if OutputDialog.RunModal() <> Action::OK then
                        exit;
                    OutputDialog.ReportFor(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ReportDowntime)
            {
                Caption = 'Report downtime';
                ToolTip = 'Report how long the selected operation stood still and why. It is posted straight away.';
                Image = Pause;

                trigger OnAction()
                var
                    DowntimeDialog: Page "MFG Downtime Dialog";
                begin
                    if DowntimeDialog.RunModal() <> Action::OK then
                        exit;
                    DowntimeDialog.ReportFor(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Events)
            {
                Caption = 'Reported events';
                ToolTip = 'View the output and downtime reported from the terminal.';
                Image = Log;
                RunObject = page "MFG Shop Floor Events";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(StartRef; Start)
                {
                }
                actionref(StopRef; Stop)
                {
                }
                actionref(ReportOutputRef; ReportOutput)
                {
                }
                actionref(ReportDowntimeRef; ReportDowntime)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Running := Engine.IsRunning(Rec);
        if Running then
            RunningStyle := 'Favorable'
        else
            RunningStyle := 'Standard';
    end;

    var
        WorkCenterNo: Code[20];
        Running: Boolean;
        RunningStyle: Text;
        StoppedMsg: Label 'The operation ran for %1 minute(s).', Comment = '%1 = the minutes the operation ran';

    local procedure ApplyWorkCenterFilter()
    begin
        if WorkCenterNo = '' then
            Rec.SetRange("Work Center No.")
        else
            Rec.SetRange("Work Center No.", WorkCenterNo);
        CurrPage.Update(false);
    end;
}
