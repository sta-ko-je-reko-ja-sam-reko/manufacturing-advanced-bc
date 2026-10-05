namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Inventory.Item;

table 85303 "MFG Order Variance"
{
    Caption = 'Production order variance';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Order Variances";
    DrillDownPageId = "MFG Order Variances";

    fields
    {
        field(1; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the finished production order.';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item the order produced.';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the production order.';
        }
        field(12; "Finished Date"; Date)
        {
            Caption = 'Finished date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the order was finished.';
        }
        field(20; "Output Cost"; Decimal)
        {
            Caption = 'Output cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the actual cost at which the output was valued, which for a standard-cost item is its standard cost.';
        }
        field(21; "Material Variance"; Decimal)
        {
            Caption = 'Material variance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the variance between the material actually consumed and the standard.';
        }
        field(22; "Capacity Variance"; Decimal)
        {
            Caption = 'Capacity variance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the variance between the capacity actually used and the standard.';
        }
        field(23; "Cap. Overhead Variance"; Decimal)
        {
            Caption = 'Capacity overhead variance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the capacity overhead variance.';
        }
        field(24; "Mfg. Overhead Variance"; Decimal)
        {
            Caption = 'Manufacturing overhead variance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the manufacturing overhead variance.';
        }
        field(25; "Subcontracted Variance"; Decimal)
        {
            Caption = 'Subcontracted variance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the subcontracting variance.';
        }
        field(30; "Total Variance"; Decimal)
        {
            Caption = 'Total variance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the sum of all variances. Positive means the order cost more than its standard.';
        }
        field(31; "Variance %"; Decimal)
        {
            Caption = 'Variance %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the total variance as a percentage of the output cost.';
        }
    }

    keys
    {
        key(PK; "Prod. Order No.")
        {
            Clustered = true;
        }
    }
}
