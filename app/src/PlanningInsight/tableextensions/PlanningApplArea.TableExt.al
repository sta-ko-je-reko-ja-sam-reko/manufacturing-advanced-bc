namespace ManufacturingAdvanced.PlanningInsight;

using System.Environment.Configuration;

tableextension 85500 "MFG Planning Appl. Area" extends "Application Area Setup"
{
    fields
    {
        field(85500; "MFG Planning Insight"; Boolean)
        {
            Caption = 'Planning insight';
            DataClassification = SystemMetadata;
        }
    }
}
