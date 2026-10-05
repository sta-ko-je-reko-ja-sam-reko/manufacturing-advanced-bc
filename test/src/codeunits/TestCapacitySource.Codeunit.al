namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.FiniteLoading;

codeunit 89019 "MFG Test Capacity Source" implements "MFG ICapacitySource"
{
    procedure DailyCapacity(WorkCenterNo: Code[20]; OnDate: Date): Decimal
    begin
        exit(480);
    end;
}
