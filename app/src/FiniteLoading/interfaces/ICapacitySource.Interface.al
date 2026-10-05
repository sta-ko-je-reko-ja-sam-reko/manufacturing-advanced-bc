namespace ManufacturingAdvanced.FiniteLoading;

interface "MFG ICapacitySource"
{
    /// <summary>
    /// Returns how much capacity a work center has on one day, in the work center's capacity unit of measure.
    /// </summary>
    /// <param name="WorkCenterNo">The work center.</param>
    /// <param name="OnDate">The day.</param>
    /// <returns>The capacity available that day.</returns>
    procedure DailyCapacity(WorkCenterNo: Code[20]; OnDate: Date): Decimal;
}
