namespace ManufacturingAdvanced.Core;

table 85002 "MFG Demo Data"
{
    Caption = 'Demo data';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the code that identifies the demo data set.';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
