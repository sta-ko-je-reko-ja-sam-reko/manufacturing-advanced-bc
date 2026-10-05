namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Capacity;

table 85403 "MFG Refresh Oper. Snapshot"
{
    Caption = 'Refresh operation snapshot';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Run No."; Integer)
        {
            Caption = 'Run no.';
            DataClassification = SystemMetadata;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry no.';
            DataClassification = SystemMetadata;
        }
        field(7; Type; Enum "Capacity Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(8; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Setup Time"; Decimal)
        {
            Caption = 'Setup time';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(13; "Run Time"; Decimal)
        {
            Caption = 'Run time';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(34; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing link code';
            DataClassification = CustomerContent;
        }
        field(51; "Routing No."; Code[20])
        {
            Caption = 'Routing no.';
            DataClassification = CustomerContent;
        }
        field(53; "Routing Reference No."; Integer)
        {
            Caption = 'Routing reference no.';
            DataClassification = CustomerContent;
        }
        field(54; "Operation No."; Code[10])
        {
            Caption = 'Operation no.';
            DataClassification = CustomerContent;
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
