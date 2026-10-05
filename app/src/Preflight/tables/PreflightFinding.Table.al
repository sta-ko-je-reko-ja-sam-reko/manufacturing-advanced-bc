namespace ManufacturingAdvanced.Preflight;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;

table 85102 "MFG Preflight Finding"
{
    Caption = 'Pre-flight finding';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Preflight Findings";
    DrillDownPageId = "MFG Preflight Findings";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the number of the finding.';
        }
        field(10; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the status the production order had when it was checked.';
        }
        field(11; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order the finding is about.';
            TableRelation = "Production Order"."No." where(Status = field("Prod. Order Status"));
        }
        field(12; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. order line no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order line the finding is about, or zero when it is about the whole order.';
        }
        field(13; "Component Line No."; Integer)
        {
            Caption = 'Component line no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the component line the finding is about, or zero when it is about the output.';
        }
        field(20; Check; Enum "MFG Preflight Check Type")
        {
            Caption = 'Check';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the check that produced the finding.';
        }
        field(21; Severity; Enum "MFG Preflight Severity")
        {
            Caption = 'Severity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how serious the finding is.';
        }
        field(22; Message; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what is wrong and what to do about it.';
        }
        field(30; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item the finding is about.';
            TableRelation = Item;
        }
        field(31; "Location Code"; Code[10])
        {
            Caption = 'Location code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the location the finding is about.';
            TableRelation = Location;
        }
        field(40; "Checked At"; DateTime)
        {
            Caption = 'Checked at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the checks ran.';
        }
        field(41; "Checked By"; Code[50])
        {
            Caption = 'Checked by';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who ran the checks, or who released the order.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Order; "Prod. Order Status", "Prod. Order No.", Severity)
        {
        }
    }
}
