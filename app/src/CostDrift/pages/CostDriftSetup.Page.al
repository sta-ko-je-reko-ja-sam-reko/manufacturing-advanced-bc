namespace ManufacturingAdvanced.CostDrift;

using ManufacturingAdvanced.Core;

page 85300 "MFG Cost Drift Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG Cost Drift Setup";
    Caption = 'Standard cost drift setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'standard cost, roll up, variance, stale cost';

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
            group(Drift)
            {
                Caption = 'Cost drift';

                field("Tolerance %"; Rec."Tolerance %")
                {
                    ApplicationArea = MFGCostDrift;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {
                    ApplicationArea = MFGCostDrift;
                }
            }
            group(Variances)
            {
                Caption = 'Order variances';

                field("Variance Days"; Rec."Variance Days")
                {
                    ApplicationArea = MFGCostDrift;
                }
            }
            part(Sources; "MFG Drift Sources")
            {
                ApplicationArea = MFGCostDrift;
                Caption = 'Compare standard cost with';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG Cost Drift Feature Setup";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        FeatureSetup.EnsureSetup(Rec);
        Engine.EnsureSources();
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
