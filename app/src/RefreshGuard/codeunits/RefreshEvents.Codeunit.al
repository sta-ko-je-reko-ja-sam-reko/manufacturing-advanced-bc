namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;

codeunit 85405 "MFG Refresh Events"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", OnBeforeCalcProdOrder, '', true, true)]
    local procedure OnBeforeCalcProdOrder(var ProductionOrder: Record "Production Order")
    var
        Locator: Codeunit "MFG Refresh Locator";
    begin
        Locator.Reactions().OnBeforeRefresh(ProductionOrder);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", OnBeforeCalculate, '', true, true)]
    local procedure OnBeforeCalculate(var ItemLedgerEntry: Record "Item Ledger Entry"; var CapacityLedgerEntry: Record "Capacity Ledger Entry"; Direction: Option Forward,Backward; CalcRouting: Boolean; CalcComponents: Boolean; var DeleteRelations: Boolean; LetDueDateDecrease: Boolean; var IsHandled: Boolean; var ProdOrderLine: Record "Prod. Order Line"; var ErrorOccured: Boolean)
    var
        Locator: Codeunit "MFG Refresh Locator";
    begin
        Locator.Reactions().OnBeforeCalculateLine(ProdOrderLine, CalcRouting, CalcComponents);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", OnAfterCalculate, '', true, true)]
    local procedure OnAfterCalculate(ProdOrderLine: Record "Prod. Order Line"; var ErrorOccured: Boolean)
    var
        Locator: Codeunit "MFG Refresh Locator";
    begin
        Locator.Reactions().OnAfterCalculateLine(ProdOrderLine);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", OnAfterRefreshProdOrder, '', true, true)]
    local procedure OnAfterRefreshProdOrder(var ProductionOrder: Record "Production Order")
    var
        Locator: Codeunit "MFG Refresh Locator";
    begin
        Locator.Reactions().OnAfterRefresh(ProductionOrder);
    end;
}
