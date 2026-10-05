namespace ManufacturingAdvanced.EngineeringChange;

interface "MFG IEcoHeader"
{
    /// <summary>
    /// Runs when an engineering change order is inserted: numbers it and records who requested it.
    /// </summary>
    /// <param name="EcoHeader">The order being inserted.</param>
    procedure Trigger_OnInsert(var EcoHeader: Record "MFG ECO Header");

    /// <summary>
    /// Runs when an engineering change order is deleted: only an open or rejected order can be, and its lines go
    /// with it.
    /// </summary>
    /// <param name="EcoHeader">The order being deleted.</param>
    procedure Trigger_OnDelete(var EcoHeader: Record "MFG ECO Header");
}
