namespace ManufacturingAdvanced.WIPControl;

table 85201 "MFG Finish Check"
{
    Caption = 'Finish check';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Finish Checks";
    DrillDownPageId = "MFG Finish Checks";

    fields
    {
        field(1; Check; Enum "MFG Finish Check Type")
        {
            Caption = 'Check';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the check.';
        }
        field(10; Severity; Enum "MFG Finish Check Severity")
        {
            Caption = 'Severity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what a finding of this check does. Block keeps the order from being finished from the proposals, Inform only notes it, and Off skips the check.';
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
