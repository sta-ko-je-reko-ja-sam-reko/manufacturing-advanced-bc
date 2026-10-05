namespace ManufacturingAdvanced.FiniteLoading;

interface "MFG IPlanWriteBack"
{
    /// <summary>
    /// Moves the operation of a load plan line to the planned starting date.
    /// </summary>
    /// <param name="LoadPlanLine">The load plan line; it fits the horizon and has a planned starting date.</param>
    /// <returns>True when the operation was moved.</returns>
    procedure Apply(LoadPlanLine: Record "MFG Load Plan Line"): Boolean;
}
