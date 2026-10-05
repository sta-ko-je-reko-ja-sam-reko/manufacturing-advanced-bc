namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;

page 85507 "MFG API Planning Rule"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgPlanning';
    APIVersion = 'v1.0';
    EntityName = 'planningRule';
    EntitySetName = 'planningRules';
    EntityCaption = 'Planning rule';
    EntitySetCaption = 'Planning rules';
    SourceTable = "MFG Planning Rule";
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
                field(advisor; Rec.Advisor)
                {
                    Caption = 'Pattern';
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
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGPlanningInsight);
        exit(true);
    end;
}
