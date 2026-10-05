namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;

table 85203 "MFG WIP Reconciliation"
{
    Caption = 'WIP reconciliation';
    DataClassification = CustomerContent;
    LookupPageId = "MFG WIP Reconciliation";
    DrillDownPageId = "MFG WIP Reconciliation";

    fields
    {
        field(1; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the production order is released or finished.';
        }
        field(2; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order.';
        }
        field(10; "Source No."; Code[20])
        {
            Caption = 'Source no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item the order produces.';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the production order.';
        }
        field(20; "Value WIP"; Decimal)
        {
            Caption = 'WIP in value entries';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the work in progress according to the order''s value entries: consumption plus capacity minus output.';
        }
        field(21; "G/L WIP"; Decimal)
        {
            Caption = 'WIP in G/L';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the net amount the general ledger holds on the WIP accounts for the order.';
        }
        field(22; Difference; Decimal)
        {
            Caption = 'Difference';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the WIP in the value entries minus the WIP in the general ledger.';
        }
        field(23; "Unposted Cost"; Decimal)
        {
            Caption = 'Cost not posted to G/L';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the actual cost of the order that has not been posted to the general ledger yet. Post Inventory Cost to G/L posts it.';
        }
        field(30; Status; Enum "MFG WIP Recon. Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the order matches, differs only by cost not posted to the general ledger yet, or needs investigating.';
        }
        field(40; "Reconciled At"; DateTime)
        {
            Caption = 'Reconciled at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the reconciliation ran.';
        }
    }

    keys
    {
        key(PK; "Prod. Order Status", "Prod. Order No.")
        {
            Clustered = true;
        }
    }
}
