namespace ManufacturingAdvanced.PlanningInsight;

using Microsoft.Inventory.Item;

table 85503 "MFG Item Planning Insight"
{
    Caption = 'Item planning insight';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Item Planning Insights";
    DrillDownPageId = "MFG Item Planning Insights";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item description.';
        }
        field(11; "Reordering Policy"; Enum "Reordering Policy")
        {
            Caption = 'Reordering policy';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item''s reordering policy.';
        }
        field(12; "Dampener Period"; Text[30])
        {
            Caption = 'Dampener period';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item''s dampener period, the shift in date planning tolerates before it reschedules.';
        }
        field(13; "Dampener Quantity"; Decimal)
        {
            Caption = 'Dampener quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the item''s dampener quantity, the change in quantity planning tolerates before it changes an order.';
        }
        field(14; "Lot Accumulation Period"; Text[30])
        {
            Caption = 'Lot accumulation period';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item''s lot accumulation period.';
        }
        field(15; "Rescheduling Period"; Text[30])
        {
            Caption = 'Rescheduling period';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item''s rescheduling period.';
        }
        field(20; "Runs With Messages"; Integer)
        {
            Caption = 'Runs with messages';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies in how many recorded planning runs the item got at least one action message.';
        }
        field(21; "New Runs"; Integer)
        {
            Caption = 'Runs with New';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies in how many runs planning proposed a new order for the item.';
        }
        field(22; "Change Qty. Runs"; Integer)
        {
            Caption = 'Runs with Change Qty.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies in how many runs planning proposed to change the quantity of an existing order.';
        }
        field(23; "Reschedule Runs"; Integer)
        {
            Caption = 'Runs with Reschedule';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies in how many runs planning proposed to move an existing order, with or without changing its quantity.';
        }
        field(24; "Cancel Runs"; Integer)
        {
            Caption = 'Runs with Cancel';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies in how many runs planning proposed to cancel an existing order.';
        }
        field(30; Advisor; Enum "MFG Planning Advisor Type")
        {
            Caption = 'Pattern';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the pattern the advice is about.';
        }
        field(31; Advice; Text[250])
        {
            Caption = 'Advice';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which planning parameter to look at, and why.';
        }
        field(40; "Analyzed At"; DateTime)
        {
            Caption = 'Analyzed at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the analysis ran.';
        }
    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
}
