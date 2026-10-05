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
            part(Checks; "MFG Finish Checks")
            {
                ApplicationArea = MFGWIPControl;
                Caption = 'Checks before finishing';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG WIP Feature Setup";
        Engine: Codeunit "MFG WIP Engine";
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
