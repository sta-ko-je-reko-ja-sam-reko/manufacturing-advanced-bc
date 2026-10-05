namespace ManufacturingAdvanced.PlanningInsight;

table 85500 "MFG Planning Setup"
{
    Caption = 'Planning insight setup';
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
            ToolTip = 'Specifies whether planning insight is enabled. Turning this on records the action messages of every planning run and shows the related pages, and the session restarts so the change takes effect.';
        }
        field(20; "Record After Planning"; Boolean)
        {
            Caption = 'Record after Calculate Plan';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the action messages of a planning worksheet are recorded automatically every time Calculate Plan finishes.';
        }
        field(30; "Churn Threshold"; Integer)
        {
            Caption = 'Pattern threshold (runs)';
            DataClassification = CustomerContent;
            MinValue = 1;
            ToolTip = 'Specifies in how many planning runs an item must get the same kind of action message before it counts as a pattern worth advice.';
        }
        field(40; "History Days"; Integer)
        {
            Caption = 'History (days)';
            DataClassification = CustomerContent;
            MinValue = 1;
            ToolTip = 'Specifies how many days of recorded planning runs the analysis looks at.';
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
