namespace ManufacturingAdvanced.ShopFloor;

using System.Environment.Configuration;

tableextension 85600 "MFG Shop Floor Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85600; "MFG Shop Floor"; Boolean)
        {
            Caption = 'Shop floor terminal';
            DataClassification = SystemMetadata;
        }
    }
}
