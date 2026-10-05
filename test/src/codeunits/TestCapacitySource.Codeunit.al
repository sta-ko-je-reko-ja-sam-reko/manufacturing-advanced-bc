namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.FiniteLoading;
using Microsoft.Manufacturing.Capacity;

codeunit 89019 "MFG Test Capacity Source" implements "MFG ICapacitySource"
{
    var
        Capacities: Dictionary of [Code[20], Decimal];

    procedure DailyCapacity(CapacityType: Enum "Capacity Type"; No: Code[20]; OnDate: Date): Decimal
    var
        Capacity: Decimal;
    begin
        if Capacities.Get(No, Capacity) then
            exit(Capacity);
        exit(480);
    end;

    procedure SetCapacity(No: Code[20]; Capacity: Decimal)
    begin
        Capacities.Set(No, Capacity);
    end;

    procedure ResetCapacities()
    begin
        Clear(Capacities);
    end;
}
