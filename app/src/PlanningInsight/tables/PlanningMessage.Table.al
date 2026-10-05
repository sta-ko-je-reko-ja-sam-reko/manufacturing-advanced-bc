namespace ManufacturingAdvanced.PlanningInsight;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Tracking;

table 85502 "MFG Planning Message"
{
    Caption = 'Recorded action message';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Planning Messages";
    DrillDownPageId = "MFG Planning Messages";

    fields
    {
        field(1; "Run No."; Integer)
        {
            Caption = 'Run no.';
            DataClassification = SystemMetadata;
            TableRelation = "MFG Planning Run";
            ToolTip = 'Specifies the planning run that produced the message.';
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the number of the message within its run.';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item.';
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the variant.';
        }
        field(12; "Location Code"; Code[10])
        {
            Caption = 'Location code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the location.';
        }
        field(20; "Action Message"; Enum "Action Message Type")
        {
            Caption = 'Action message';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what planning proposed: New, Change Qty., Reschedule, Resched. & Chg. Qty. or Cancel.';
        }
        field(21; "Original Due Date"; Date)
        {
            Caption = 'Original due date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the due date of the existing supply before the message.';
        }
        field(22; "Due Date"; Date)
        {
            Caption = 'Due date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the due date planning proposed.';
        }
        field(23; "Original Quantity"; Decimal)
        {
            Caption = 'Original quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity of the existing supply before the message.';
        }
        field(24; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity planning proposed.';
        }
        field(30; "Ref. Order Type"; Enum "Requisition Ref. Order Type")
        {
            Caption = 'Ref. order type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the kind of supply order the message is about.';
        }
        field(31; "Ref. Order No."; Code[20])
        {
            Caption = 'Ref. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the supply order the message is about.';
        }
    }

    keys
    {
        key(PK; "Run No.", "Entry No.")
        {
            Clustered = true;
        }
        key(Item; "Item No.", "Action Message")
        {
        }
    }
}
