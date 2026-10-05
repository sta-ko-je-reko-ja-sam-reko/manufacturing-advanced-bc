namespace ManufacturingAdvanced.RefreshGuard;

using System.Environment.Configuration;

tableextension 85400 "MFG Refresh Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85400; "MFG Refresh Guard"; Boolean)
        {
            Caption = 'Refresh protection';
            DataClassification = SystemMetadata;
        }
    }
}
