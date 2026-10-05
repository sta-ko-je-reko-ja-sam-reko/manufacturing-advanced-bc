namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;
using System.Environment.Configuration;

codeunit 85401 "MFG Refresh App Area Sub."
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", OnGetEssentialExperienceAppAreas, '', true, true)]
    local procedure SetAppAreasOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        TempApplicationAreaSetup."MFG Refresh Guard" := FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGRefreshGuard);
    end;
}
