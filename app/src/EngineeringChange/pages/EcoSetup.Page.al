namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;

page 85800 "MFG ECO Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG ECO Setup";
    Caption = 'Engineering change setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'ECO, engineering change order, BOM version, routing version';

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
                field("Approval Method"; Rec."Approval Method")
                {
                    ApplicationArea = MFGEngineeringChange;
                }
                field("Separate Approver"; Rec."Separate Approver")
                {
                    ApplicationArea = MFGEngineeringChange;
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';

                field("ECO Nos."; Rec."ECO Nos.")
                {
                    ApplicationArea = MFGEngineeringChange;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
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
