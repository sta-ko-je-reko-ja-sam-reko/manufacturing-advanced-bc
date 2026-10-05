namespace ManufacturingAdvanced.Preflight;

using System.Environment.Configuration;

tableextension 85100 "MFG Preflight Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85100; "MFG Preflight"; Boolean)
        {
            Caption = 'Release pre-flight';
            DataClassification = SystemMetadata;
        }
    }
}
