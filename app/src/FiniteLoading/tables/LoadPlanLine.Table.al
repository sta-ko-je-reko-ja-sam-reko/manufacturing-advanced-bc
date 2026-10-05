namespace ManufacturingAdvanced.FiniteLoading;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;

table 85701 "MFG Load Plan Line"
{
    Caption = 'Load plan line';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Load Plan";
    DrillDownPageId = "MFG Load Plan";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the number of the line.';
        }
        field(10; "Work Center No."; Code[20])
        {
            Caption = 'Work center no.';
            DataClassification = CustomerContent;
            TableRelation = "Work Center";
            ToolTip = 'Specifies the work center.';
        }
        field(11; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the status of the production order.';
        }
        field(12; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order.';
        }
        field(13; "Routing Reference No."; Integer)
        {
            Caption = 'Routing reference no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the routing reference of the operation.';
        }
        field(14; "Routing No."; Code[20])
        {
            Caption = 'Routing no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the routing of the operation.';
        }
        field(15; "Operation No."; Code[10])
        {
            Caption = 'Operation no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the operation.';
        }
        field(16; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the operation description.';
        }
        field(20; "Due Date"; Date)
        {
            Caption = 'Due date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the production order is due.';
        }
        field(21; Need; Decimal)
        {
            Caption = 'Capacity need';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the capacity the operation still needs, in the work center''s capacity unit of measure.';
        }
        field(22; "Current Starting Date"; Date)
        {
            Caption = 'Current starting date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the starting date the operation has now, from infinite planning.';
        }
        field(23; "Current Ending Date"; Date)
        {
            Caption = 'Current ending date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the ending date the operation has now, from infinite planning.';
        }
        field(30; "Sequence No."; Integer)
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the order in which the operation is loaded onto the work center.';
        }
        field(31; "Planned Starting Date"; Date)
        {
            Caption = 'Finite starting date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the day the operation can start when the work center''s capacity is respected.';
        }
        field(32; "Planned Ending Date"; Date)
        {
            Caption = 'Finite ending date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the day the operation can finish when the work center''s capacity is respected.';
        }
        field(33; "Fits Horizon"; Boolean)
        {
            Caption = 'Fits the horizon';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the operation fits in the work center''s capacity within the horizon.';
        }
        field(34; Late; Boolean)
        {
            Caption = 'Late';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the operation finishes after the order''s due date, or does not fit at all.';
        }
        field(35; "Days Late"; Integer)
        {
            Caption = 'Days late';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many days after the due date the operation finishes.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Sequence; "Work Center No.", "Sequence No.")
        {
        }
        key(DueDate; "Work Center No.", "Due Date", "Prod. Order No.", "Operation No.")
        {
        }
        key(OrderNo; "Work Center No.", "Prod. Order No.", "Operation No.")
        {
        }
        key(NeedSize; "Work Center No.", Need, "Due Date")
        {
        }
    }
}
