namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.EngineeringChange;
using Microsoft.Manufacturing.Document;

codeunit 89024 "MFG Test ECO Order Refresh" implements "MFG IEcoOrderRefresh"
{
    var
        RefreshedOrders: List of [Code[20]];

    procedure Refresh(ProductionOrder: Record "Production Order")
    begin
        RefreshedOrders.Add(ProductionOrder."No.");
    end;

    procedure WasRefreshed(OrderNo: Code[20]): Boolean
    begin
        exit(RefreshedOrders.Contains(OrderNo));
    end;

    procedure RefreshCount(): Integer
    begin
        exit(RefreshedOrders.Count());
    end;
}
