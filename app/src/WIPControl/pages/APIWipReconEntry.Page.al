namespace ManufacturingAdvanced.WIPControl;

page 85210 "MFG API WIP Recon. Entry"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgWip';
    APIVersion = 'v1.0';
    EntityName = 'wipReconciliationEntry';
    EntitySetName = 'wipReconciliationEntries';
    EntityCaption = 'WIP reconciliation entry';
    EntitySetCaption = 'WIP reconciliation entries';
    SourceTable = "MFG WIP Recon. Entry";
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
                field(reconciledOn; Rec."Reconciled On")
                {
                    Caption = 'Reconciled on';
                }
                field(prodOrderStatus; Rec."Prod. Order Status")
                {
                    Caption = 'Prod. order status';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
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
            }
        }
    }
}
