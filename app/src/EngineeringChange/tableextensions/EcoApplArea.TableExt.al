namespace ManufacturingAdvanced.EngineeringChange;

using System.Environment.Configuration;

tableextension 85800 "MFG ECO Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85800; "MFG Engineering Change"; Boolean)
        {
            Caption = 'Engineering change';
            DataClassification = SystemMetadata;
        }
    }
}
