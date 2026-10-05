namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;
using System.Environment.Configuration;

codeunit 85201 "MFG WIP App Area Sub."
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", OnGetEssentialExperienceAppAreas, '', true, true)]
    local procedure SetAppAreasOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        TempApplicationAreaSetup."MFG WIP Control" := FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGWipControl);
    end;
}
