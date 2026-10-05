namespace ManufacturingAdvanced.PlanningInsight;

page 85506 "MFG API Planning Message"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgPlanning';
    APIVersion = 'v1.0';
    EntityName = 'planningMessage';
    EntitySetName = 'planningMessages';
    EntityCaption = 'Recorded action message';
    EntitySetCaption = 'Recorded action messages';
    SourceTable = "MFG Planning Message";
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
                field(runNo; Rec."Run No.")
                {
                    Caption = 'Run no.';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry no.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant code';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location code';
                }
                field(actionMessage; Rec."Action Message")
                {
                    Caption = 'Action message';
                }
                field(originalDueDate; Rec."Original Due Date")
                {
                    Caption = 'Original due date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due date';
                }
                field(originalQuantity; Rec."Original Quantity")
                {
                    Caption = 'Original quantity';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(refOrderType; Rec."Ref. Order Type")
                {
                    Caption = 'Ref. order type';
                }
                field(refOrderNo; Rec."Ref. Order No.")
                {
                    Caption = 'Ref. order no.';
                }
            }
        }
    }
}
