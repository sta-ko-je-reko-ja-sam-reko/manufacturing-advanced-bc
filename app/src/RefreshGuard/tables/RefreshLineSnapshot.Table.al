namespace ManufacturingAdvanced.RefreshGuard;

table 85405 "MFG Refresh Line Snapshot"
{
    Caption = 'Refresh line snapshot';
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
        field(3; "Line No."; Integer)
        {
            Caption = 'Line no.';
            DataClassification = CustomerContent;
        }
        field(4; Occurrence; Integer)
        {
            Caption = 'Occurrence';
            DataClassification = SystemMetadata;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant code';
            DataClassification = CustomerContent;
        }
        field(13; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location code';
            DataClassification = CustomerContent;
        }
        field(23; "Bin Code"; Code[20])
        {
            Caption = 'Bin code';
            DataClassification = CustomerContent;
        }
        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(47; "Due Date"; Date)
        {
            Caption = 'Due date';
            DataClassification = CustomerContent;
        }
        field(60; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM no.';
            DataClassification = CustomerContent;
        }
        field(61; "Routing No."; Code[20])
        {
            Caption = 'Routing no.';
            DataClassification = CustomerContent;
        }
        field(80; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of measure code';
            DataClassification = CustomerContent;
        }
        field(85750; "Production BOM Version Code"; Code[20])
        {
            Caption = 'Production BOM version code';
            DataClassification = CustomerContent;
        }
        field(85751; "Routing Version Code"; Code[20])
        {
            Caption = 'Routing version code';
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
