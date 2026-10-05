namespace ManufacturingAdvanced.FiniteLoading;

using System.Environment.Configuration;

tableextension 85700 "MFG Loading Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85700; "MFG Finite Loading"; Boolean)
        {
            Caption = 'Finite loading';
            DataClassification = SystemMetadata;
        }
    }
}
