namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;

page 85104 "MFG API Preflight Check"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgPreflight';
    APIVersion = 'v1.0';
    EntityName = 'preflightCheck';
    EntitySetName = 'preflightChecks';
    EntityCaption = 'Pre-flight check';
    EntitySetCaption = 'Pre-flight checks';
    SourceTable = "MFG Preflight Check";
    Extensible = false;
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(check; Rec.Check)
                {
                    Caption = 'Check';
                    Editable = false;
                }
                field(severity; Rec.Severity)
                {
                    Caption = 'Severity';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGPreflight);
        exit(true);
    end;
}
