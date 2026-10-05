namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;

table 85204 "MFG WIP Recon. Entry"
{
    Caption = 'WIP reconciliation entry';
    DataClassification = CustomerContent;
    LookupPageId = "MFG WIP Recon. Entries";
    DrillDownPageId = "MFG WIP Recon. Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the number of the entry.';
        }
        field(2; "Reconciled On"; Date)
        {
            Caption = 'Reconciled on';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the work date the reconciliation ran on.';
        }
        field(3; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the production order was released or finished.';
        }
        field(4; "Prod. Order No."; Code[20])
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
        field(20; "Value WIP"; Decimal)
        {
            Caption = 'WIP in value entries';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the work in progress according to the order''s value entries on that day.';
        }
        field(21; "G/L WIP"; Decimal)
        {
            Caption = 'WIP in G/L';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies what the general ledger held on the WIP accounts for the order on that day.';
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
            ToolTip = 'Specifies the actual cost of the order that had not been posted to the general ledger yet.';
        }
        field(30; Status; Enum "MFG WIP Recon. Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the order matched, differed only by cost not posted to the general ledger yet, or needed investigating.';
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
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ByOrder; "Prod. Order No.", "Reconciled On")
        {
        }
        key(ByDate; "Reconciled On")
        {
        }
    }
}
