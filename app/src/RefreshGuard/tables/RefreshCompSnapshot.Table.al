namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Setup;

table 85402 "MFG Refresh Comp. Snapshot"
{
    Caption = 'Refresh component snapshot';
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
        field(3; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. order line no.';
            DataClassification = CustomerContent;
        }
        field(4; Occurrence; Integer)
        {
            Caption = 'Occurrence';
            DataClassification = SystemMetadata;
        }
        field(5; "Component Line No."; Integer)
        {
            Caption = 'Component line no.';
            DataClassification = CustomerContent;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of measure code';
            DataClassification = CustomerContent;
        }
        field(19; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing link code';
            DataClassification = CustomerContent;
        }
        field(20; "Scrap %"; Decimal)
        {
            Caption = 'Scrap %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant code';
            DataClassification = CustomerContent;
        }
        field(28; "Flushing Method"; Enum "Flushing Method")
        {
            Caption = 'Flushing method';
            DataClassification = CustomerContent;
        }
        field(30; "Location Code"; Code[10])
        {
            Caption = 'Location code';
            DataClassification = CustomerContent;
        }
        field(33; "Bin Code"; Code[20])
        {
            Caption = 'Bin code';
            DataClassification = CustomerContent;
        }
        field(45; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
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
