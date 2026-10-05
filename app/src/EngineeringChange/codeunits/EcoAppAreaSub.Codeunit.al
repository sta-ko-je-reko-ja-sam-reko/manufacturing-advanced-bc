namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;
using System.Environment.Configuration;

codeunit 85801 "MFG ECO App Area Sub."
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", OnGetEssentialExperienceAppAreas, '', true, true)]
    local procedure SetAppAreasOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        TempApplicationAreaSetup."MFG Engineering Change" := FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGEngineeringChange);
    end;
}
