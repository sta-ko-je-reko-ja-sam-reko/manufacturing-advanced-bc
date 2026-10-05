namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;

page 85204 "MFG API Finish Check"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgWip';
    APIVersion = 'v1.0';
    EntityName = 'finishCheck';
    EntitySetName = 'finishChecks';
    EntityCaption = 'Finish check';
    EntitySetCaption = 'Finish checks';
    SourceTable = "MFG Finish Check";
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
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGWipControl);
        exit(true);
    end;
}
