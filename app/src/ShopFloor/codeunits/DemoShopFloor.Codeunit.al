namespace ManufacturingAdvanced.ShopFloor;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Setup;

codeunit 85605 "MFG Demo Shop Floor"
{
    Access = Public;

    var
        ScrapCodeTok: Label 'MFG-QUAL', Locked = true;
        ScrapDescriptionLbl: Label 'Quality reject at the operation';
        StopCodeTok: Label 'MFG-BRKDN', Locked = true;
        StopDescriptionLbl: Label 'Machine breakdown';
        PackageCodeTok: Label 'MFG-SHOPFLOOR', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Shop Floor Terminal';

    /// <summary>
    /// Seeds the shop floor terminal sample data. Idempotent. Creates scrap code MFG-QUAL and stop code
    /// MFG-BRKDN, proposes them in the setup when it has none, and builds the feature's configuration package. It
    /// posts nothing: output and downtime are only ever posted by an operator.
    /// </summary>
    procedure Import()
    var
        Setup: Record "MFG Shop Floor Setup";
        FeatureSetup: Codeunit "MFG Shop Floor Feature Setup";
    begin
        EnsureScrapCode();
        EnsureStopCode();

        FeatureSetup.EnsureSetup(Setup);
        if Setup."Default Scrap Code" = '' then
            Setup."Default Scrap Code" := ScrapCodeTok;
        if Setup."Default Stop Code" = '' then
            Setup."Default Stop Code" := StopCodeTok;
        Setup.Modify(true);

        CreateConfigPackage();
    end;

    local procedure EnsureScrapCode()
    var
        Scrap: Record Scrap;
    begin
        if Scrap.Get(ScrapCodeTok) then
            exit;
        Scrap.Init();
        Scrap.Code := ScrapCodeTok;
        Scrap.Description := CopyStr(ScrapDescriptionLbl, 1, MaxStrLen(Scrap.Description));
        Scrap.Insert(true);
    end;

    local procedure EnsureStopCode()
    var
        Stop: Record Stop;
    begin
        if Stop.Get(StopCodeTok) then
            exit;
        Stop.Init();
        Stop.Code := StopCodeTok;
        Stop.Description := CopyStr(StopDescriptionLbl, 1, MaxStrLen(Stop.Description));
        Stop.Insert(true);
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Shop Floor Session");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Shop Floor Event");
    end;
}
