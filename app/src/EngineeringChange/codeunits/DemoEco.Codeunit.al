namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.ProductionBOM;

codeunit 85807 "MFG Demo ECO"
{
    Access = Public;

    var
        DemoEcoNoTok: Label 'ECO-DEMO-01', Locked = true;
        DemoDescriptionLbl: Label 'Sample change: review the components of a production BOM';
        DemoReasonLbl: Label 'Sample engineering change created by the Manufacturing Advanced sample data.';
        DemoChangeLbl: Label 'Edit the new version to try the change out.';
        PackageCodeTok: Label 'MFG-ECO', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Engineering Change';

    /// <summary>
    /// Seeds the engineering change sample data. Idempotent. Creates the number series when the setup has none, an
    /// open engineering change ECO-DEMO-01 on the production BOM of the first certified manufactured item, with
    /// its new version under development, and builds the feature's configuration package. Nothing is certified.
    /// </summary>
    procedure Import()
    var
        Setup: Record "MFG ECO Setup";
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        FeatureSetup.EnsureNoSeries(Setup);
        CreateDemoChange();
        CreateConfigPackage();
    end;

    /// <summary>
    /// The number of the sample engineering change.
    /// </summary>
    /// <returns>The fixed number.</returns>
    procedure DemoEcoNo(): Code[20]
    begin
        exit(DemoEcoNoTok);
    end;

    local procedure CreateDemoChange()
    var
        EcoHeader: Record "MFG ECO Header";
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
        BomNo: Code[20];
    begin
        if EcoHeader.Get(DemoEcoNoTok) then
            exit;
        if not FindCertifiedBom(BomNo) then
            exit;

        EcoHeader.Init();
        EcoHeader."No." := DemoEcoNoTok;
        EcoHeader.Description := DemoDescriptionLbl;
        EcoHeader.Reason := DemoReasonLbl;
        EcoHeader."Effective Date" := CalcDate('<+1M>', WorkDate());
        EcoHeader.Insert(true);

        EcoLine.Init();
        EcoLine."ECO No." := EcoHeader."No.";
        EcoLine."Line No." := 10000;
        EcoLine.Validate("Object Type", EcoLine."Object Type"::MFGProductionBom);
        EcoLine.Validate("No.", BomNo);
        EcoLine."Change Description" := DemoChangeLbl;
        EcoLine.Insert(true);

        EcoObject := EcoLine."Object Type";
        EcoObject.CreateVersion(EcoLine);
    end;

    local procedure FindCertifiedBom(var BomNo: Code[20]): Boolean
    var
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        Item.SetLoadFields("Production BOM No.");
        Item.SetRange("Replenishment System", Item."Replenishment System"::"Prod. Order");
        Item.SetFilter("Production BOM No.", '<>%1', '');
        if not Item.FindSet() then
            exit(false);

        repeat
            ProductionBOMHeader.SetLoadFields(Status);
            if ProductionBOMHeader.Get(Item."Production BOM No.") then
                if ProductionBOMHeader.Status = ProductionBOMHeader.Status::Certified then begin
                    BomNo := ProductionBOMHeader."No.";
                    exit(true);
                end;
        until Item.Next() = 0;
        exit(false);
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG ECO Header");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG ECO Line");
    end;
}
