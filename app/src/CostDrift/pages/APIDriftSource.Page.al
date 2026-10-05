namespace ManufacturingAdvanced.CostDrift;

using ManufacturingAdvanced.Core;

page 85305 "MFG API Drift Source"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgCostDrift';
    APIVersion = 'v1.0';
    EntityName = 'driftSource';
    EntitySetName = 'driftSources';
    EntityCaption = 'Cost drift source';
    EntitySetCaption = 'Cost drift sources';
    SourceTable = "MFG Drift Source";
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
                field(source; Rec.Source)
                {
                    Caption = 'Source';
                    Editable = false;
                }
                field(active; Rec.Active)
                {
                    Caption = 'Active';
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
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGCostDrift);
        exit(true);
    end;
}
