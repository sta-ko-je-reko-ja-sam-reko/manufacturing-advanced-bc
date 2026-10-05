namespace ManufacturingAdvanced.EngineeringChange;

enum 85801 "MFG ECO Object Type" implements "MFG IEcoObject"
{
    Caption = 'Engineering change object type';
    Extensible = true;
    DefaultImplementation = "MFG IEcoObject" = "MFG ECO No Object";

    value(0; MFGNone)
    {
        Caption = ' ';
    }
    value(1; MFGProductionBom)
    {
        Caption = 'Production BOM';
        Implementation = "MFG IEcoObject" = "MFG ECO Production BOM";
    }
    value(2; MFGRouting)
    {
        Caption = 'Routing';
        Implementation = "MFG IEcoObject" = "MFG ECO Routing";
    }
}
