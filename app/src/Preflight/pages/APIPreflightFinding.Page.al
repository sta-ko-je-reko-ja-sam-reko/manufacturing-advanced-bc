namespace ManufacturingAdvanced.Preflight;

page 85103 "MFG API Preflight Finding"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgPreflight';
    APIVersion = 'v1.0';
    EntityName = 'preflightFinding';
    EntitySetName = 'preflightFindings';
    EntityCaption = 'Pre-flight finding';
    EntitySetCaption = 'Pre-flight findings';
    SourceTable = "MFG Preflight Finding";
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
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry no.';
                }
                field(prodOrderStatus; Rec."Prod. Order Status")
                {
                    Caption = 'Prod. order status';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(prodOrderLineNo; Rec."Prod. Order Line No.")
                {
                    Caption = 'Prod. order line no.';
                }
                field(componentLineNo; Rec."Component Line No.")
                {
                    Caption = 'Component line no.';
                }
                field(check; Rec.Check)
                {
                    Caption = 'Check';
                }
                field(severity; Rec.Severity)
                {
                    Caption = 'Severity';
                }
                field(message; Rec.Message)
                {
                    Caption = 'Message';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location code';
                }
                field(checkedAt; Rec."Checked At")
                {
                    Caption = 'Checked at';
                }
                field(checkedBy; Rec."Checked By")
                {
                    Caption = 'Checked by';
                }
            }
        }
    }
}
