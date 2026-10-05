namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Foundation.NoSeries;

table 85800 "MFG ECO Setup"
{
    Caption = 'Engineering change setup';
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
            ToolTip = 'Specifies whether engineering change orders are enabled. Turning this on shows the related pages, and the session restarts so the change takes effect.';
        }
        field(20; "ECO Nos."; Code[20])
        {
            Caption = 'Engineering change nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series that numbers engineering change orders.';
        }
        field(30; "Separate Approver"; Boolean)
        {
            Caption = 'Approver must differ from requester';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the user who requested an engineering change is barred from approving it.';
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
