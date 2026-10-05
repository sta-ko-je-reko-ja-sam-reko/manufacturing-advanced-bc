namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Setup;

table 85602 "MFG Shop Floor Event"
{
    Caption = 'Shop floor event';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Shop Floor Events";
    DrillDownPageId = "MFG Shop Floor Events";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the number of the event.';
        }
        field(10; "Event Type"; Enum "MFG Shop Floor Event Type")
        {
            Caption = 'Event type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the operator reported output or downtime.';
        }
        field(11; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the released production order.';
        }
        field(12; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. order line no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order line.';
        }
        field(13; "Operation No."; Code[10])
        {
            Caption = 'Operation no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the operation, or blank for an order line without a routing.';
        }
        field(14; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item produced.';
        }
        field(20; "Output Quantity"; Decimal)
        {
            Caption = 'Output quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the good quantity reported.';
        }
        field(21; "Scrap Quantity"; Decimal)
        {
            Caption = 'Scrap quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the scrapped quantity reported.';
        }
        field(22; "Scrap Code"; Code[10])
        {
            Caption = 'Scrap code';
            DataClassification = CustomerContent;
            TableRelation = Scrap;
            ToolTip = 'Specifies why the quantity was scrapped.';
        }
        field(23; "Run Minutes"; Decimal)
        {
            Caption = 'Run minutes';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the run time posted with the output, in minutes.';
        }
        field(30; "Stop Minutes"; Decimal)
        {
            Caption = 'Stop minutes';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the downtime reported, in minutes.';
        }
        field(31; "Stop Code"; Code[10])
        {
            Caption = 'Stop code';
            DataClassification = CustomerContent;
            TableRelation = Stop;
            ToolTip = 'Specifies why the operation stood still.';
        }
        field(40; "Reported At"; DateTime)
        {
            Caption = 'Reported at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the event was reported and posted.';
        }
        field(41; "Reported By"; Code[50])
        {
            Caption = 'Reported by';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the operator who reported the event.';
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
