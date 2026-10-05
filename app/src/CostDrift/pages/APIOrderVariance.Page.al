namespace ManufacturingAdvanced.CostDrift;

page 85306 "MFG API Order Variance"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgCostDrift';
    APIVersion = 'v1.0';
    EntityName = 'orderVariance';
    EntitySetName = 'orderVariances';
    EntityCaption = 'Production order variance';
    EntitySetCaption = 'Production order variances';
    SourceTable = "MFG Order Variance";
    Extensible = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
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
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(finishedDate; Rec."Finished Date")
                {
                    Caption = 'Finished date';
                }
                field(outputCost; Rec."Output Cost")
                {
                    Caption = 'Output cost';
                }
                field(materialVariance; Rec."Material Variance")
                {
                    Caption = 'Material variance';
                }
                field(capacityVariance; Rec."Capacity Variance")
                {
                    Caption = 'Capacity variance';
                }
                field(capOverheadVariance; Rec."Cap. Overhead Variance")
                {
                    Caption = 'Capacity overhead variance';
                }
                field(mfgOverheadVariance; Rec."Mfg. Overhead Variance")
                {
                    Caption = 'Manufacturing overhead variance';
                }
                field(subcontractedVariance; Rec."Subcontracted Variance")
                {
                    Caption = 'Subcontracted variance';
                }
                field(totalVariance; Rec."Total Variance")
                {
                    Caption = 'Total variance';
                }
                field(variancePercent; Rec."Variance %")
                {
                    Caption = 'Variance %';
                }
            }
        }
    }
}
