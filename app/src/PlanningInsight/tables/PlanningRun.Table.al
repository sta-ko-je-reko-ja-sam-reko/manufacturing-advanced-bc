namespace ManufacturingAdvanced.PlanningInsight;

table 85501 "MFG Planning Run"
{
    Caption = 'Recorded planning run';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Planning Runs";
    DrillDownPageId = "MFG Planning Runs";

    fields
    {
        field(1; "Run No."; Integer)
        {
            Caption = 'Run no.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the number of the recorded planning run.';
        }
        field(10; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet template';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the planning worksheet template.';
        }
        field(11; "Journal Batch Name"; Code[10])
        {
            Caption = 'Worksheet batch';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the planning worksheet batch.';
        }
        field(20; "Recorded At"; DateTime)
        {
            Caption = 'Recorded at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the action messages were recorded.';
        }
        field(21; "Recorded By"; Code[50])
        {
            Caption = 'Recorded by';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who ran the planning.';
        }
        field(30; Messages; Integer)
        {
            Caption = 'Messages';
            FieldClass = FlowField;
            CalcFormula = count("MFG Planning Message" where("Run No." = field("Run No.")));
            Editable = false;
            ToolTip = 'Specifies how many action messages the run produced.';
        }
    }

    keys
    {
        key(PK; "Run No.")
        {
            Clustered = true;
        }
    }
}
