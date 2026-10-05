namespace ManufacturingAdvanced.EngineeringChange;

enum 85802 "MFG ECO Approval Method" implements "MFG IEcoApproval"
{
    Caption = 'ECO approval method';
    Extensible = true;
    DefaultImplementation = "MFG IEcoApproval" = "MFG ECO Built-in Approval";

    value(0; MFGBuiltIn)
    {
        Caption = 'On the change card';
        Implementation = "MFG IEcoApproval" = "MFG ECO Built-in Approval";
    }
    value(1; MFGWorkflow)
    {
        Caption = 'Approval workflow';
        Implementation = "MFG IEcoApproval" = "MFG ECO Workflow Approval";
    }
}
