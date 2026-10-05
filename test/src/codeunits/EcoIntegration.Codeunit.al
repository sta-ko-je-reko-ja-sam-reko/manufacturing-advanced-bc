namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.EngineeringChange;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using System.TestLibraries.Utilities;

codeunit 89017 "MFG ECO Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";

    [Test]
    procedure AChangeCreatesApprovesAndCertifiesANewBomVersion()
    var
        ComponentItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        ProductionBOMLine: Record "Production BOM Line";
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] A certified production BOM with one component, and a change on it effective tomorrow
        Prepare();
        LibraryInventory.CreateItem(ComponentItem);
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItem."No.", 1);
        CreateChange(EcoHeader, ProductionBOMHeader."No.", WorkDate() + 1);

        // [WHEN] Its versions are created
        Engine.CreateVersions(EcoHeader);

        // [THEN] The BOM has a version named after the change, under development, with the component copied
        Assert.IsTrue(ProductionBOMVersion.Get(ProductionBOMHeader."No.", EcoHeader."No."), 'The new version exists.');
        Assert.AreEqual(ProductionBOMVersion.Status::"Under Development", ProductionBOMVersion.Status, 'The new version is under development.');
        ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLine.SetRange("Version Code", EcoHeader."No.");
        ProductionBOMLine.SetRange("No.", ComponentItem."No.");
        Assert.RecordIsNotEmpty(ProductionBOMLine);

        // [WHEN] The change is submitted, approved and implemented
        Engine.SubmitForApproval(EcoHeader);
        Engine.Approve(EcoHeader);
        Engine.Implement(EcoHeader);

        // [THEN] The version is certified from the effective date, and the change is implemented
        ProductionBOMVersion.Get(ProductionBOMHeader."No.", EcoHeader."No.");
        Assert.AreEqual(ProductionBOMVersion.Status::Certified, ProductionBOMVersion.Status, 'The new version is certified.');
        Assert.AreEqual(WorkDate() + 1, ProductionBOMVersion."Starting Date", 'The version starts on the effective date.');
        EcoHeader.Get(EcoHeader."No.");
        Assert.AreEqual(EcoHeader.Status::MFGImplemented, EcoHeader.Status, 'The change is implemented.');
    end;

    [Test]
    procedure TheImpactListsOpenOrdersUsingTheBom()
    var
        ComponentItem: Record Item;
        ParentItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionOrder: Record "Production Order";
        EcoHeader: Record "MFG ECO Header";
        TempImpact: Record "MFG ECO Impact" temporary;
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] A firm planned order of an item made from a BOM, and a change on that BOM
        Prepare();
        LibraryInventory.CreateItem(ComponentItem);
        LibraryInventory.CreateItem(ParentItem);
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItem."No.", 1);
        ParentItem.Validate("Replenishment System", ParentItem."Replenishment System"::"Prod. Order");
        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify(true);
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, ProductionOrder.Status::"Firm Planned", ProductionOrder."Source Type"::Item, ParentItem."No.", 1);
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
        CreateChange(EcoHeader, ProductionBOMHeader."No.", WorkDate() + 1);

        // [WHEN] The impact is asked for
        Engine.GetImpact(EcoHeader, TempImpact);

        // [THEN] The order is listed
        TempImpact.SetRange("Prod. Order No.", ProductionOrder."No.");
        Assert.RecordIsNotEmpty(TempImpact);
    end;

    local procedure CreateChange(var EcoHeader: Record "MFG ECO Header"; BomNo: Code[20]; EffectiveDate: Date)
    var
        EcoLine: Record "MFG ECO Line";
    begin
        EcoHeader.Init();
        EcoHeader."Effective Date" := EffectiveDate;
        EcoHeader.Insert(true);

        EcoLine.Init();
        EcoLine."ECO No." := EcoHeader."No.";
        EcoLine."Line No." := 10000;
        EcoLine.Validate("Object Type", EcoLine."Object Type"::MFGProductionBom);
        EcoLine.Validate("No.", BomNo);
        EcoLine.Insert(true);
    end;

    local procedure Prepare()
    var
        Setup: Record "MFG ECO Setup";
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := true;
        Setup."Separate Approver" := false;
        Setup.Modify(true);
        FeatureSetup.EnsureNoSeries(Setup);
    end;
}
