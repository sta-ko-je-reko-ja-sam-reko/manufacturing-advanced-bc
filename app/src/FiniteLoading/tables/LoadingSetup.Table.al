namespace ManufacturingAdvanced.FiniteLoading;

table 85700 "MFG Loading Setup"
{
    Caption = 'Finite loading setup';
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
            ToolTip = 'Specifies whether finite loading is enabled. Turning this on shows the load plan, and the session restarts so the change takes effect.';
        }
        field(20; "Horizon Days"; Integer)
        {
            Caption = 'Horizon (days)';
            DataClassification = CustomerContent;
            MinValue = 1;
            ToolTip = 'Specifies how many days from the work date the work center''s capacity is loaded. Work that does not fit in the horizon is marked as not fitting.';
        }
        field(30; Sequencing; Enum "MFG Sequencing Strategy")
        {
            Caption = 'Sequencing';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the order in which open operations are loaded onto the work center''s capacity.';
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
