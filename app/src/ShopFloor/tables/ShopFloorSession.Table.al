namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.WorkCenter;

table 85601 "MFG Shop Floor Session"
{
    Caption = 'Shop floor session';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Shop Floor Sessions";
    DrillDownPageId = "MFG Shop Floor Sessions";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the number of the session.';
        }
        field(10; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the released production order.';
        }
        field(11; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. order line no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order line.';
        }
        field(12; "Routing Reference No."; Integer)
        {
            Caption = 'Routing reference no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the routing reference of the operation.';
        }
        field(13; "Routing No."; Code[20])
        {
            Caption = 'Routing no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the routing of the operation.';
        }
        field(14; "Operation No."; Code[10])
        {
            Caption = 'Operation no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the operation.';
        }
        field(15; "Work Center No."; Code[20])
        {
            Caption = 'Work center no.';
            DataClassification = CustomerContent;
            TableRelation = "Work Center";
            ToolTip = 'Specifies the work center.';
        }
        field(16; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item produced.';
        }
        field(20; Operator; Code[50])
        {
            Caption = 'Operator';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who started the operation.';
        }
        field(21; "Started At"; DateTime)
        {
            Caption = 'Started at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the operator started the operation.';
        }
        field(22; "Stopped At"; DateTime)
        {
            Caption = 'Stopped at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the operator stopped the operation.';
        }
        field(23; Status; Enum "MFG Shop Floor Session Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the operation is running or stopped.';
        }
        field(24; Minutes; Decimal)
        {
            Caption = 'Minutes';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the minutes between start and stop.';
        }
        field(25; "Run Time Posted"; Boolean)
        {
            Caption = 'Run time posted';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the minutes were posted as run time.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Operation; "Prod. Order No.", "Routing Reference No.", "Routing No.", "Operation No.", Operator, Status)
        {
        }
    }
}
