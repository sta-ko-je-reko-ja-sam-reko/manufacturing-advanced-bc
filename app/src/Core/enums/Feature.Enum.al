namespace ManufacturingAdvanced.Core;

enum 85000 "MFG Feature" implements "MFG IFeatureSetup"
{
    Caption = 'Manufacturing advanced feature';
    Extensible = true;
    DefaultImplementation = "MFG IFeatureSetup" = "MFG Default Feature Setup";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
}
