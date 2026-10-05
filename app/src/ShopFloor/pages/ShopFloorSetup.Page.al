namespace ManufacturingAdvanced.ShopFloor;

using ManufacturingAdvanced.Core;

page 85600 "MFG Shop Floor Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFG Shop Floor Setup";
    Caption = 'Shop floor terminal setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'shop floor data collection, operator, output reporting';

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
                field("Post Run Time"; Rec."Post Run Time")
                {
                    ApplicationArea = MFGShopFloor;
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults';

                field("Default Scrap Code"; Rec."Default Scrap Code")
                {
                    ApplicationArea = MFGShopFloor;
                }
                field("Default Stop Code"; Rec."Default Stop Code")
                {
                    ApplicationArea = MFGShopFloor;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureSetup: Codeunit "MFG Shop Floor Feature Setup";
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
