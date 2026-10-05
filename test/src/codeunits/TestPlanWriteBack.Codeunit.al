namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.FiniteLoading;

codeunit 89022 "MFG Test Plan Write-Back" implements "MFG IPlanWriteBack"
{
    var
        AppliedOrders: List of [Code[20]];

    procedure Apply(LoadPlanLine: Record "MFG Load Plan Line"): Boolean
    begin
        AppliedOrders.Add(LoadPlanLine."Prod. Order No.");
        exit(true);
    end;

    procedure WasApplied(OrderNo: Code[20]): Boolean
    begin
        exit(AppliedOrders.Contains(OrderNo));
    end;

    procedure ResetApplied()
    begin
        Clear(AppliedOrders);
    end;
}
