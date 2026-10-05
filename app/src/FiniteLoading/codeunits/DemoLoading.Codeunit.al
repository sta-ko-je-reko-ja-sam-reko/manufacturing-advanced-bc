namespace ManufacturingAdvanced.FiniteLoading;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

codeunit 85708 "MFG Demo Loading"
{
    Access = Public;

    var
        PackageCodeTok: Label 'MFG-LOADING', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Finite Loading';

    /// <summary>
    /// Seeds the finite loading sample data. Builds the load plan of the first work center that has open operations
    /// on firm planned or released orders, and the feature's configuration package. Changes no production order.
    /// </summary>
    procedure Import()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Setup: Record "MFG Loading Setup";
        FeatureSetup: Codeunit "MFG Loading Feature Setup";
        Engine: Codeunit "MFG Loading Engine";
    begin
        FeatureSetup.EnsureSetup(Setup);

        ProdOrderRoutingLine.SetLoadFields("Work Center No.");
        ProdOrderRoutingLine.SetFilter(Status, '%1|%2', ProdOrderRoutingLine.Status::"Firm Planned", ProdOrderRoutingLine.Status::Released);
        ProdOrderRoutingLine.SetFilter("Work Center No.", '<>%1', '');
        if ProdOrderRoutingLine.FindFirst() then
            Engine.CalculatePlan(ProdOrderRoutingLine."Work Center No.");

        CreateConfigPackage();
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Load Plan Line");
    end;
}
