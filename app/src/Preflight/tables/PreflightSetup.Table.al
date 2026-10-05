namespace ManufacturingAdvanced.Preflight;

table 85100 "MFG Preflight Setup"
{
    Caption = 'Release pre-flight setup';
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
            ToolTip = 'Specifies whether release pre-flight is enabled. Turning this on shows the related pages and actions and starts checking production orders, and the session restarts so the change takes effect.';
        }
        field(20; "Check on Release"; Boolean)
        {
            Caption = 'Check on release';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the checks run automatically when a production order is about to be released. When this is off, the checks run only when someone chooses Run pre-flight.';
        }
        field(21; "Block on Errors"; Boolean)
        {
            Caption = 'Block release on errors';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether a production order with findings of severity Error is refused release. When this is off, errors are treated like warnings.';
        }
        field(22; "Confirm Warnings"; Boolean)
        {
            Caption = 'Ask before releasing with warnings';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the user is asked to confirm a release that has warnings. When this is off, warnings are only recorded.';
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
