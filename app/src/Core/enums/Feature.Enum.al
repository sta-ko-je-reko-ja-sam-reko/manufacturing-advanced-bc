namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;

enum 85000 "MFG Feature" implements "MFG IFeatureSetup"
{
    Caption = 'Manufacturing advanced feature';
    Extensible = true;
    DefaultImplementation = "MFG IFeatureSetup" = "MFG Default Feature Setup";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
    value(1; MFGPreflight)
    {
        Caption = 'Release pre-flight';
        Implementation = "MFG IFeatureSetup" = "MFG Preflight Feature Setup";
    }
}
