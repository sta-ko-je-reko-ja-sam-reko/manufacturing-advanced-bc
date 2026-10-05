namespace ManufacturingAdvanced.PlanningInsight;

table 85504 "MFG Planning Rule"
{
    Caption = 'Planning rule';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Planning Rules";
    DrillDownPageId = "MFG Planning Rules";

    fields
    {
        field(1; Advisor; Enum "MFG Planning Advisor Type")
        {
            Caption = 'Advisor';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the pattern the rule looks for.';
        }
        field(10; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the rule gives advice when the analysis runs.';
        }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the rule looks for.';
        }
    }

    keys
    {
        key(PK; Advisor)
        {
            Clustered = true;
        }
    }
}
