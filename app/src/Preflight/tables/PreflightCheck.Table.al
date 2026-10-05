namespace ManufacturingAdvanced.Preflight;

table 85101 "MFG Preflight Check"
{
    Caption = 'Pre-flight check';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Preflight Checks";
    DrillDownPageId = "MFG Preflight Checks";

    fields
    {
        field(1; Check; Enum "MFG Preflight Check Type")
        {
            Caption = 'Check';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the check.';
        }
        field(10; Severity; Enum "MFG Preflight Severity")
        {
            Caption = 'Severity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what a finding of this check does. Error refuses the release when blocking is on, Warning asks or records, and Off skips the check.';
        }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the check looks for.';
        }
    }

    keys
    {
        key(PK; Check)
        {
            Clustered = true;
        }
    }
}
