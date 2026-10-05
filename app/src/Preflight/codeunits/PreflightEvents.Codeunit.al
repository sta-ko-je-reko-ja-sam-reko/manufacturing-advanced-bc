namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

codeunit 85105 "MFG Preflight Events"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", OnBeforeChangeStatusOnProdOrder, '', true, true)]
    local procedure OnBeforeChangeStatusOnProdOrder(var ProductionOrder: Record "Production Order"; NewStatus: Option Quote,Planned,"Firm Planned",Released,Finished)
    var
        Locator: Codeunit "MFG Preflight Locator";
    begin
        Locator.Reactions().OnBeforeChangeStatus(ProductionOrder, Enum::"Production Order Status".FromInteger(NewStatus));
    end;
}
