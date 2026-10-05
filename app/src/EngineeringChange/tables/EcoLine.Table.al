namespace ManufacturingAdvanced.EngineeringChange;

table 85802 "MFG ECO Line"
{
    Caption = 'Engineering change line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ECO No."; Code[20])
        {
            Caption = 'ECO no.';
            DataClassification = CustomerContent;
            TableRelation = "MFG ECO Header";
            ToolTip = 'Specifies the engineering change order.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line no.';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the number of the line.';
        }
        field(10; "Object Type"; Enum "MFG ECO Object Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the line changes a production BOM or a routing.';
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production BOM or routing that changes.';

            trigger OnValidate()
            begin
                Handler().ValidateNo(Rec);
            end;
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the production BOM or routing.';
        }
        field(20; "New Version Code"; Code[20])
        {
            Caption = 'New version';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the version the change is made in. It is created by Create versions and certified when the change is implemented.';
        }
        field(30; "Change Description"; Text[250])
        {
            Caption = 'What changes';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what is changed in this BOM or routing.';
        }
    }

    keys
    {
        key(PK; "ECO No.", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure Handler(): Interface "MFG IEcoObject"
    begin
        exit(Rec."Object Type");
    end;
}
