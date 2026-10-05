namespace ManufacturingAdvanced.WIPControl;

table 85200 "MFG WIP Setup"
{
    Caption = 'WIP control setup';
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
            ToolTip = 'Specifies whether WIP control is enabled. Turning this on shows the finish proposals and the related actions, and the session restarts so the change takes effect.';
        }
        field(20; "Min. Days Since Output"; Integer)
        {
            Caption = 'Min. days since last output';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies how many days must have passed since the last output was posted before an order whose output is complete is proposed for finishing. Zero proposes it at once.';
        }
        field(30; "Update Unit Cost"; Boolean)
        {
            Caption = 'Update unit cost on finish';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether finishing an order updates the unit cost of the item it produced, as the Update Unit Cost option of Change Status does.';
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
