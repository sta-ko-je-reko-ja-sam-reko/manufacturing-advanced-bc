namespace ManufacturingAdvanced.RefreshGuard;

table 85400 "MFG Refresh Setup"
{
    Caption = 'Refresh protection setup';
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
            ToolTip = 'Specifies whether refresh protection is enabled. Turning this on records what every refresh of a production order changes, shows the related pages and actions, and the session restarts so the change takes effect.';
        }
        field(20; "Notify on Changes"; Boolean)
        {
            Caption = 'Notify after a refresh with changes';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether a notification offers to show what a refresh changed, right after the refresh.';
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
