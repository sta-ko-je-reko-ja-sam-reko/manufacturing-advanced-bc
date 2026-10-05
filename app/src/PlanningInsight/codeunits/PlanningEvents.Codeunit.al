namespace ManufacturingAdvanced.PlanningInsight;

using Microsoft.Manufacturing.Planning;

codeunit 85505 "MFG Planning Events"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Plan - Plan. Wksh.", OnAfterItemOnPostDataItem, '', true, true)]
    local procedure OnAfterItemOnPostDataItem(var CurrTemplateName: Code[10]; var CurrWorksheetName: Code[10])
    var
        Locator: Codeunit "MFG Planning Locator";
    begin
        Locator.Reactions().OnAfterCalculatePlan(CurrTemplateName, CurrWorksheetName);
    end;
}
