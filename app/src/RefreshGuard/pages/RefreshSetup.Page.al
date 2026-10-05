namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;

page 85400 "MFG Refresh Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG Refresh Setup";
    Caption = 'Refresh protection setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'refresh production order, lost changes, components, routing';

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
                field("Notify on Changes"; Rec."Notify on Changes")
                {
                    ApplicationArea = MFGRefreshGuard;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG Refresh Feature Setup";
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
