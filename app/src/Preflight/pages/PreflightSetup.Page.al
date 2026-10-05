namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;

page 85100 "MFG Preflight Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG Preflight Setup";
    Caption = 'Release pre-flight setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'production order release check, routing link, backward flushing, production bin';

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
            group(Release)
            {
                Caption = 'On release';

                field("Check on Release"; Rec."Check on Release")
                {
                    ApplicationArea = MFGPreflight;
                }
                field("Block on Errors"; Rec."Block on Errors")
                {
                    ApplicationArea = MFGPreflight;
                }
                field("Confirm Warnings"; Rec."Confirm Warnings")
                {
                    ApplicationArea = MFGPreflight;
                }
            }
            part(Checks; "MFG Preflight Checks")
            {
                ApplicationArea = MFGPreflight;
                Caption = 'Checks';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG Preflight Feature Setup";
        Engine: Codeunit "MFG Preflight Engine";
    begin
        FeatureSetup.EnsureSetup(Rec);
        Engine.EnsureChecks();
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
