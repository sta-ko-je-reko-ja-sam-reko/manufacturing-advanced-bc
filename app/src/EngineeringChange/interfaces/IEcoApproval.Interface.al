namespace ManufacturingAdvanced.EngineeringChange;

interface "MFG IEcoApproval"
{
    /// <summary>
    /// Sends a checked, open engineering change for approval.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Submit(var EcoHeader: Record "MFG ECO Header");

    /// <summary>
    /// Checks that the current user may approve or reject the change directly on the change card; errors if not.
    /// </summary>
    /// <param name="EcoHeader">The change pending approval.</param>
    procedure CheckDirectDecision(EcoHeader: Record "MFG ECO Header");

    /// <summary>
    /// Withdraws an approval request that is still pending, before the change is reopened.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Cancel(var EcoHeader: Record "MFG ECO Header");
}
