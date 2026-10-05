namespace ManufacturingAdvanced.RefreshGuard;

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

    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", OnAfterRefreshProdOrder, '', true, true)]
    local procedure OnAfterRefreshProdOrder(var ProductionOrder: Record "Production Order")
    var
        Locator: Codeunit "MFG Refresh Locator";
    begin
        Locator.Reactions().OnAfterRefresh(ProductionOrder);
    end;
}
