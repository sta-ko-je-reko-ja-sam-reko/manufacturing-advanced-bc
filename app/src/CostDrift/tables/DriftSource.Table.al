namespace ManufacturingAdvanced.CostDrift;

table 85301 "MFG Drift Source"
{
    Caption = 'Cost drift source';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Drift Sources";
    DrillDownPageId = "MFG Drift Sources";

    fields
    {
        field(1; Source; Enum "MFG Drift Source Type")
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the current standard cost is compared with.';
        }
        field(10; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this comparison runs when cost drift is calculated.';
        }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the source compares.';
        }
    }

    keys
    {
        key(PK; Source)
        {
            Clustered = true;
        }
    }
}
