namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.WIPControl;

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
    value(2; MFGWipControl)
    {
        Caption = 'WIP control';
        Implementation = "MFG IFeatureSetup" = "MFG WIP Feature Setup";
    }
    value(3; MFGRefreshGuard)
    {
        Caption = 'Refresh protection';
        Implementation = "MFG IFeatureSetup" = "MFG Refresh Feature Setup";
    }
}
