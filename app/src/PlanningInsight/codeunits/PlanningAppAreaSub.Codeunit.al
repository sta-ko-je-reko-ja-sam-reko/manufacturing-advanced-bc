namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;
using System.Environment.Configuration;

codeunit 85501 "MFG Planning App Area Sub."
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", OnGetEssentialExperienceAppAreas, '', true, true)]
    local procedure SetAppAreasOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        TempApplicationAreaSetup."MFG Planning Insight" := FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGPlanningInsight);
    end;
}
