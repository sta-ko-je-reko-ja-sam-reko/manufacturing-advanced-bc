namespace ManufacturingAdvanced.FiniteLoading;

using Microsoft.Manufacturing.Capacity;

codeunit 85703 "MFG Calendar Capacity" implements "MFG ICapacitySource"
{
    Access = Public;

    /// <summary>
    /// Sums the effective capacity of the work center's calendar entries for the day, as the standard Calculate
    /// Work Center Calendar created them.
    /// </summary>
    /// <param name="WorkCenterNo">The work center.</param>
    /// <param name="OnDate">The day.</param>
    /// <returns>The effective capacity that day.</returns>
    procedure DailyCapacity(WorkCenterNo: Code[20]; OnDate: Date): Decimal
    var
        CalendarEntry: Record "Calendar Entry";
    begin
        CalendarEntry.SetRange("Capacity Type", CalendarEntry."Capacity Type"::"Work Center");
        CalendarEntry.SetRange("No.", WorkCenterNo);
        CalendarEntry.SetRange(Date, OnDate);
        CalendarEntry.CalcSums("Capacity (Effective)");
        exit(CalendarEntry."Capacity (Effective)");
    end;
}
