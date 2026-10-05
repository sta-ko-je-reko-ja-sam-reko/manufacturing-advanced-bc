namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;

page 85200 "MFG WIP Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG WIP Setup";
    Caption = 'WIP control setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'work in progress, finish production orders, unfinished orders';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("MFG Enabled"; Rec."MFG Enabled")
                {
                }
            }
            group(Proposals)
            {
                Caption = 'Finish proposals';

                field("Min. Days Since Output"; Rec."Min. Days Since Output")
                {
                    ApplicationArea = MFGWIPControl;
                }
                field("Update Unit Cost"; Rec."Update Unit Cost")
                {
                    ApplicationArea = MFGWIPControl;
                }
            }
            group(Reconciliation)
            {
                Caption = 'Reconciliation with G/L';

                field("Reconciliation Tolerance"; Rec."Reconciliation Tolerance")
                {
                    ApplicationArea = MFGWIPControl;
                }
                field("Reconciliation Days"; Rec."Reconciliation Days")
                {
                    ApplicationArea = MFGWIPControl;
                }
                field("Keep History (Days)"; Rec."Keep History (Days)")
                {
                    ApplicationArea = MFGWIPControl;
                }
            }
            group(Schedule)
            {
                Caption = 'Daily run';

                field(DailyRunScheduled; DailyRunScheduled)
                {
                    ApplicationArea = MFGWIPControl;
                    Caption = 'Daily run scheduled';
                    ToolTip = 'Specifies whether a job queue entry suggests the finish proposals and reconciles WIP every day.';
                    Editable = false;
                }
            }
            part(Checks; "MFG Finish Checks")
            {
                ApplicationArea = MFGWIPControl;
                Caption = 'Checks before finishing';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ScheduleDailyRun)
            {
                ApplicationArea = MFGWIPControl;
                Caption = 'Schedule daily run';
                ToolTip = 'Create a job queue entry that suggests the finish proposals and reconciles WIP with the general ledger every day at 02:00.';
                Image = Calendar;

                trigger OnAction()
                var
                    JobScheduler: Codeunit "MFG WIP Job Scheduler";
                begin
                    JobScheduler.Schedule(020000T);
                    DailyRunScheduled := JobScheduler.IsScheduled();
                end;
            }
            action(RemoveDailyRun)
            {
                ApplicationArea = MFGWIPControl;
                Caption = 'Remove daily run';
                ToolTip = 'Delete the job queue entry of the daily WIP run.';
                Image = Delete;

                trigger OnAction()
                var
                    JobScheduler: Codeunit "MFG WIP Job Scheduler";
                begin
                    JobScheduler.Unschedule();
                    DailyRunScheduled := JobScheduler.IsScheduled();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ScheduleDailyRunRef; ScheduleDailyRun)
                {
                }
                actionref(RemoveDailyRunRef; RemoveDailyRun)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG WIP Feature Setup";
        Engine: Codeunit "MFG WIP Engine";
        JobScheduler: Codeunit "MFG WIP Job Scheduler";
    begin
        FeatureSetup.EnsureSetup(Rec);
        Engine.EnsureChecks();
        OpeningEnabled := Rec."MFG Enabled";
        DailyRunScheduled := JobScheduler.IsScheduled();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ApplyEnabledChangeIfNeeded();
        exit(true);
    end;

    var
        OpeningEnabled: Boolean;
        DailyRunScheduled: Boolean;

    local procedure ApplyEnabledChangeIfNeeded()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        if not Rec.Get() then
            exit;
        if Rec."MFG Enabled" = OpeningEnabled then
            exit;

        FeatureMgt.ApplyExperienceChange();
    end;
}
