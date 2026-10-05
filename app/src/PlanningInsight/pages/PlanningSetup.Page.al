namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;

page 85500 "MFG Planning Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG Planning Setup";
    Caption = 'Planning insight setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'action messages, MRP, planning worksheet, dampener';

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
                field("Record After Planning"; Rec."Record After Planning")
                {
                    ApplicationArea = MFGPlanningInsight;
                }
            }
            group(Analysis)
            {
                Caption = 'Analysis';

                field("Churn Threshold"; Rec."Churn Threshold")
                {
                    ApplicationArea = MFGPlanningInsight;
                }
                field("History Days"; Rec."History Days")
                {
                    ApplicationArea = MFGPlanningInsight;
                }
            }
            part(Rules; "MFG Planning Rules")
            {
                ApplicationArea = MFGPlanningInsight;
                Caption = 'Patterns to look for';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG Planning Feature Setup";
        Engine: Codeunit "MFG Planning Engine";
    begin
        FeatureSetup.EnsureSetup(Rec);
        Engine.EnsureRules();
        OpeningEnabled := Rec."MFG Enabled";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ApplyEnabledChangeIfNeeded();
        exit(true);
    end;

    var
        OpeningEnabled: Boolean;

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
