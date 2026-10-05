namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Inventory.Item;

table 85302 "MFG Cost Drift Line"
{
    Caption = 'Cost drift line';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Cost Drift";
    DrillDownPageId = "MFG Cost Drift";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the standard-cost item whose standard cost has drifted.';
        }
        field(10; Source; Enum "MFG Drift Source Type")
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the proposed cost comes from.';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item description.';
        }
        field(12; "Replenishment System"; Enum "Replenishment System")
        {
            Caption = 'Replenishment system';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how the item is replenished.';
        }
        field(20; "Current Standard Cost"; Decimal)
        {
            Caption = 'Current standard cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the standard cost on the item card.';
        }
        field(21; "Proposed Standard Cost"; Decimal)
        {
            Caption = 'Proposed standard cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the standard cost the source arrives at today.';
        }
        field(22; "Drift Amount"; Decimal)
        {
            Caption = 'Drift amount';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the proposed standard cost minus the current one, per unit.';
        }
        field(23; "Drift %"; Decimal)
        {
            Caption = 'Drift %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the drift as a percentage of the current standard cost.';
        }
        field(30; "Last Unit Cost Calc. Date"; Date)
        {
            Caption = 'Last cost calculation';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the item''s standard cost was last calculated.';
        }
        field(40; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the line is sent to the standard cost worksheet when you choose Send to worksheet.';
        }
        field(41; Transferred; Boolean)
        {
            Caption = 'Sent to worksheet';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the line has been sent to the standard cost worksheet.';
        }
        field(50; "Calculated At"; DateTime)
        {
            Caption = 'Calculated at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the drift was calculated.';
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
