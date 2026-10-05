namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;

table 85803 "MFG ECO Impact"
{
    Caption = 'Engineering change impact';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the number of the impact line.';
        }
        field(10; "Object Type"; Enum "MFG ECO Object Type")
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the impact comes from a production BOM or a routing.';
        }
        field(11; "Object No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the production BOM or routing.';
        }
        field(20; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the status of the production order that uses it.';
        }
        field(21; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the production order that uses it.';
        }
        field(22; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. order line no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the production order line.';
        }
        field(23; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = SystemMetadata;
            TableRelation = Item;
            ToolTip = 'Specifies the item the order produces.';
        }
        field(24; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity of the line.';
        }
        field(25; "Due Date"; Date)
        {
            Caption = 'Due date';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when the line is due.';
        }
        field(26; "Version In Use"; Code[20])
        {
            Caption = 'Version in use';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the version the line was calculated with. A refresh after the effective date picks up the new version.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
