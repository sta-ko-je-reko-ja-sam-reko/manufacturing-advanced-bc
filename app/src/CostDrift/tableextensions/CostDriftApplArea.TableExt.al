namespace ManufacturingAdvanced.CostDrift;

using System.Environment.Configuration;

tableextension 85300 "MFG Cost Drift Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85300; "MFG Cost Drift"; Boolean)
        {
            Caption = 'Standard cost drift';
            DataClassification = SystemMetadata;
        }
    }
}
