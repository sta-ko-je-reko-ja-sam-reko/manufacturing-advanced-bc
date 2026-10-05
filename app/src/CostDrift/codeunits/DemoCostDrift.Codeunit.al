namespace ManufacturingAdvanced.CostDrift;

using ManufacturingAdvanced.Core;

codeunit 85306 "MFG Demo Cost Drift"
{
    Access = Public;

    var
        PackageCodeTok: Label 'MFG-COSTDRIFT', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Standard Cost Drift';

    /// <summary>
    /// Seeds the standard cost drift sample data. Idempotent. Creates the source configuration and the
    /// standard cost worksheet, calculates the drift and the order variances from the company's own items and
    /// finished production orders, and builds the feature's configuration package. It changes no item cost and
    /// posts nothing.
    /// </summary>
    procedure Import()
    var
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        Engine.EnsureSources();
        Engine.EnsureWorksheet();
        Engine.Calculate();
        Engine.CalculateVariances();
        CreateConfigPackage();
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Drift Source");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Cost Drift Line");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Order Variance");
    end;
}
