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
        field(40; "Reconciliation Tolerance"; Decimal)
        {
            Caption = 'Reconciliation tolerance';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            MinValue = 0;
            ToolTip = 'Specifies the largest difference between the WIP in the value entries and in the general ledger that still counts as matched.';
        }
        field(41; "Reconciliation Days"; Integer)
        {
            Caption = 'Reconcile orders finished in the last (days)';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies how many days back, from the work date, finished production orders are reconciled together with every released one.';
        }
        field(50; "Keep History (Days)"; Integer)
        {
            Caption = 'Keep reconciliation history (days)';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies how many days of reconciliation history are kept. Older entries are removed when the reconciliation runs. 0 keeps everything.';
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
