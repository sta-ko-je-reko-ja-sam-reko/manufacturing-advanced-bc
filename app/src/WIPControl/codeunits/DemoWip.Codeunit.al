namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;

codeunit 85205 "MFG Demo WIP"
{
    Access = Public;

    var
        PackageCodeTok: Label 'MFG-WIP', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - WIP Control';

    /// <summary>
    /// Seeds the WIP control sample data. Idempotent. Creates the check configuration, builds the finish
    /// proposals from the released production orders the company already has, and builds the feature's
    /// configuration package. It posts nothing: an order only appears among the proposals when its output
    /// has really been posted.
    /// </summary>
    procedure Import()
    var
        Engine: Codeunit "MFG WIP Engine";
    begin
        Engine.EnsureChecks();
        Engine.Suggest();
        CreateConfigPackage();
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Finish Check");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Finish Proposal");
    end;
}
