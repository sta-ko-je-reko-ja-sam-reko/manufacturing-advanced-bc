namespace ManufacturingAdvanced.FiniteLoading;

using ManufacturingAdvanced.Core;

page 85700 "MFG Loading Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG Loading Setup";
    Caption = 'Finite loading setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'finite capacity, scheduling, sequencing, work center load';

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
                field("Horizon Days"; Rec."Horizon Days")
                {
                    ApplicationArea = MFGFiniteLoading;
                }
                field(Sequencing; Rec.Sequencing)
                {
                    ApplicationArea = MFGFiniteLoading;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG Loading Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Rec);
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
