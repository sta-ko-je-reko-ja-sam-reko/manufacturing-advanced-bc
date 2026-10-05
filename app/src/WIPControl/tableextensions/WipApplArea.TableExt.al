namespace ManufacturingAdvanced.WIPControl;

using System.Environment.Configuration;

tableextension 85200 "MFG WIP Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85200; "MFG WIP Control"; Boolean)
        {
            Caption = 'WIP control';
            DataClassification = SystemMetadata;
        }
    }
}
