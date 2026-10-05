namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

table 85401 "MFG Refresh Run"
{
    Caption = 'Refresh run';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Refresh Runs";
    DrillDownPageId = "MFG Refresh Runs";

    fields
    {
        field(1; "Run No."; Integer)
        {
            Caption = 'Run no.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the number of the refresh run.';
        }
        field(10; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the status of the production order that was refreshed.';
        }
        field(11; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order that was refreshed.';
            TableRelation = "Production Order"."No." where(Status = field("Prod. Order Status"));
        }
        field(20; "Refreshed At"; DateTime)
        {
            Caption = 'Refreshed at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the order was refreshed.';
        }
        field(21; "Refreshed By"; Code[50])
        {
            Caption = 'Refreshed by';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who refreshed the order.';
        }
        field(22; Completed; Boolean)
        {
            Caption = 'Completed';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the refresh finished and was compared with the snapshot.';
        }
        field(30; Changes; Integer)
        {
            Caption = 'Changes';
            FieldClass = FlowField;
            CalcFormula = count("MFG Refresh Change" where("Run No." = field("Run No.")));
            Editable = false;
            ToolTip = 'Specifies how many differences the refresh made.';
        }
        field(31; "Open Changes"; Integer)
        {
            Caption = 'Open changes';
            FieldClass = FlowField;
            CalcFormula = count("MFG Refresh Change" where("Run No." = field("Run No."), Restorable = const(true), Restored = const(false)));
            Editable = false;
            ToolTip = 'Specifies how many differences could still be restored.';
        }
    }

    keys
    {
        key(PK; "Run No.")
        {
            Clustered = true;
        }
        key(Order; "Prod. Order Status", "Prod. Order No.")
        {
        }
    }
}
