namespace ManufacturingAdvanced.EngineeringChange;

enum 85800 "MFG ECO Status"
{
    Caption = 'Engineering change status';
    Extensible = false;

    value(0; MFGOpen)
    {
        Caption = 'Open';
    }
    value(1; MFGPendingApproval)
    {
        Caption = 'Pending approval';
    }
    value(2; MFGApproved)
    {
        Caption = 'Approved';
    }
    value(3; MFGImplemented)
    {
        Caption = 'Implemented';
    }
    value(4; MFGRejected)
    {
        Caption = 'Rejected';
    }
}
