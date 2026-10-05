namespace ManufacturingAdvanced.WIPControl;

page 85208 "MFG API WIP Reconciliation"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgWip';
    APIVersion = 'v1.0';
    EntityName = 'wipReconciliation';
    EntitySetName = 'wipReconciliations';
    EntityCaption = 'WIP reconciliation';
    EntitySetCaption = 'WIP reconciliations';
    SourceTable = "MFG WIP Reconciliation";
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
                field(prodOrderStatus; Rec."Prod. Order Status")
                {
                    Caption = 'Prod. order status';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source no.';
                }
                field(valueWip; Rec."Value WIP")
                {
                    Caption = 'WIP in value entries';
                }
                field(glWip; Rec."G/L WIP")
                {
                    Caption = 'WIP in G/L';
                }
                field(difference; Rec.Difference)
                {
                    Caption = 'Difference';
                }
                field(unpostedCost; Rec."Unposted Cost")
                {
                    Caption = 'Cost not posted to G/L';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(reconciledAt; Rec."Reconciled At")
                {
                    Caption = 'Reconciled at';
                }
            }
        }
    }
}
