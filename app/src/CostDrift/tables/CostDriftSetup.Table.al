namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Manufacturing.StandardCost;

table 85300 "MFG Cost Drift Setup"
{
    Caption = 'Standard cost drift setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = CustomerContent;
        }
        field(10; "MFG Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether standard cost drift is enabled. Turning this on shows the cost drift and order variance pages, and the session restarts so the change takes effect.';
        }
        field(20; "Tolerance %"; Decimal)
        {
            Caption = 'Tolerance %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            ToolTip = 'Specifies how far, as a percentage of the current standard cost, the proposed cost may be from it before the item is listed.';
        }
        field(30; "Worksheet Name"; Code[10])
        {
            Caption = 'Standard cost worksheet';
            DataClassification = CustomerContent;
            TableRelation = "Standard Cost Worksheet Name";
            ToolTip = 'Specifies the standard cost worksheet that drift lines are sent to, where you review and implement them with the standard Implement Standard Cost Changes.';
        }
        field(40; "Variance Days"; Integer)
        {
            Caption = 'Variance period (days)';
            DataClassification = CustomerContent;
            MinValue = 1;
            ToolTip = 'Specifies how many days back, from the work date, finished production orders are included in the order variances.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
