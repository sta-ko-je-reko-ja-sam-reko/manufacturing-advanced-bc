namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

table 85404 "MFG Refresh Change"
{
    Caption = 'Refresh change';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Refresh Changes";
    DrillDownPageId = "MFG Refresh Changes";

    fields
    {
        field(1; "Run No."; Integer)
        {
            Caption = 'Run no.';
            DataClassification = SystemMetadata;
            TableRelation = "MFG Refresh Run";
            ToolTip = 'Specifies the refresh run that made the change.';
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the number of the change within its run.';
        }
        field(10; Kind; Enum "MFG Refresh Object Kind")
        {
            Caption = 'Kind';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the change is to a component or an operation.';
        }
        field(11; "Change Type"; Enum "MFG Refresh Change Type")
        {
            Caption = 'Change type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the refresh changed a value, removed a line that existed before, or added a line that did not.';
        }
        field(12; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. order status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the status of the production order.';
        }
        field(13; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order.';
        }
        field(14; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. order line no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order line the component belongs to.';
        }
        field(20; Subject; Text[100])
        {
            Caption = 'Subject';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the component or operation that changed.';
        }
        field(21; "Field No."; Integer)
        {
            Caption = 'Field no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the number of the field that changed, or zero for a whole line.';
        }
        field(22; "Field Caption"; Text[80])
        {
            Caption = 'Field';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the field that changed.';
        }
        field(23; "Old Value"; Text[250])
        {
            Caption = 'Before refresh';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the value before the refresh.';
        }
        field(24; "New Value"; Text[250])
        {
            Caption = 'After refresh';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the value after the refresh.';
        }
        field(30; "Snapshot Entry No."; Integer)
        {
            Caption = 'Snapshot entry no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the snapshot row holding the line as it was before the refresh.';
        }
        field(31; "Current Line No."; Integer)
        {
            Caption = 'Current line no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the component line as it is after the refresh.';
        }
        field(32; "Routing No."; Code[20])
        {
            Caption = 'Routing no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the routing of the operation.';
        }
        field(33; "Routing Reference No."; Integer)
        {
            Caption = 'Routing reference no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the routing reference of the operation.';
        }
        field(34; "Operation No."; Code[10])
        {
            Caption = 'Operation no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the operation.';
        }
        field(40; Restorable; Boolean)
        {
            Caption = 'Restorable';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the app can put the value from before the refresh back.';
        }
        field(41; Restored; Boolean)
        {
            Caption = 'Restored';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the value from before the refresh has been put back.';
        }
    }

    keys
    {
        key(PK; "Run No.", "Entry No.")
        {
            Clustered = true;
        }
    }
}
