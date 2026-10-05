namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.RefreshGuard;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using System.TestLibraries.Utilities;

codeunit 89008 "MFG Refresh Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";

    [Test]
    procedure ARefreshDiscardsAManualQuantityAndRestoreBringsItBack()
    var
        ProductionOrder: Record "Production Order";
        ProdOrderComponent: Record "Prod. Order Component";
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
    begin
        // [GIVEN] Refresh protection is on, and a refreshed order whose component quantity per was changed to 5 by hand
        SetFeature(true);
        CreateRefreshedOrder(ProductionOrder);
        FindComponent(ProductionOrder, ProdOrderComponent);
        ProdOrderComponent.Validate("Quantity per", 5);
        ProdOrderComponent.Modify(true);

        // [WHEN] The order's components are recalculated by Refresh Production Order
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, false, false, true, false);

        // [THEN] The refresh put the BOM quantity back, and the change was recorded
        FindComponent(ProductionOrder, ProdOrderComponent);
        Assert.AreEqual(1, ProdOrderComponent."Quantity per", 'The refresh recalculates the quantity per from the BOM.');
        Change.SetRange("Prod. Order No.", ProductionOrder."No.");
        Change.SetRange("Field No.", ProdOrderComponent.FieldNo("Quantity per"));
        Assert.RecordCount(Change, 1);

        // [WHEN] The change is restored
        Engine.RestoreAll(Change);

        // [THEN] The component has the quantity per entered by hand again
        FindComponent(ProductionOrder, ProdOrderComponent);
        Assert.AreEqual(5, ProdOrderComponent."Quantity per", 'Restore should put the manual quantity back.');
    end;

    [Test]
    procedure ARefreshRemovesAManualComponentAndRestoreRecreatesIt()
    var
        ProductionOrder: Record "Production Order";
        ProdOrderComponent: Record "Prod. Order Component";
        ExtraItem: Record Item;
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
    begin
        // [GIVEN] Refresh protection is on, and a refreshed order with a component added by hand
        SetFeature(true);
        CreateRefreshedOrder(ProductionOrder);
        LibraryInventory.CreateItem(ExtraItem);
        AddComponentByHand(ProductionOrder, ExtraItem."No.", 2);

        // [WHEN] The order's components are recalculated
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, false, false, true, false);

        // [THEN] The manual component is gone, and its removal was recorded
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetRange("Item No.", ExtraItem."No.");
        Assert.RecordIsEmpty(ProdOrderComponent);
        Change.SetRange("Prod. Order No.", ProductionOrder."No.");
        Change.SetRange("Change Type", Change."Change Type"::MFGRemoved);
        Assert.RecordCount(Change, 1);

        // [WHEN] The removal is restored
        Engine.RestoreAll(Change);

        // [THEN] The component is back with its quantity per
        ProdOrderComponent.FindFirst();
        Assert.AreEqual(2, ProdOrderComponent."Quantity per", 'The re-created component should carry the quantity per it had.');
    end;

    [Test]
    procedure NothingIsRecordedWhileTheFeatureIsOff()
    var
        ProductionOrder: Record "Production Order";
        ProdOrderComponent: Record "Prod. Order Component";
        RefreshRun: Record "MFG Refresh Run";
    begin
        // [GIVEN] Refresh protection is off, and a refreshed order with a manual quantity
        SetFeature(false);
        CreateRefreshedOrder(ProductionOrder);
        FindComponent(ProductionOrder, ProdOrderComponent);
        ProdOrderComponent.Validate("Quantity per", 5);
        ProdOrderComponent.Modify(true);

        // [WHEN] The order's components are recalculated
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, false, false, true, false);

        // [THEN] No run is recorded
        RefreshRun.SetRange("Prod. Order No.", ProductionOrder."No.");
        Assert.RecordIsEmpty(RefreshRun);
    end;

    [Test]
    procedure ARecalculationOutsideTheBatchJobIsRecorded()
    var
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
        RefreshRun: Record "MFG Refresh Run";
        Change: Record "MFG Refresh Change";
        CalculateProdOrder: Codeunit "Calculate Prod. Order";
    begin
        // [GIVEN] Refresh protection is on, and a refreshed order whose component quantity per was changed to 5 by hand
        SetFeature(true);
        CreateRefreshedOrder(ProductionOrder);
        FindComponent(ProductionOrder, ProdOrderComponent);
        ProdOrderComponent.Validate("Quantity per", 5);
        ProdOrderComponent.Modify(true);

        // [WHEN] The line is recalculated from its BOM directly, as planning or a customization would
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.FindFirst();
        CalculateProdOrder.Calculate(ProdOrderLine, 1, true, true, true, false);

        // [THEN] The quantity per is back to the BOM's, and a run from a line recalculation recorded the change
        FindComponent(ProductionOrder, ProdOrderComponent);
        Assert.AreEqual(1, ProdOrderComponent."Quantity per", 'The recalculation takes the quantity per from the BOM.');
        RefreshRun.SetRange("Prod. Order No.", ProductionOrder."No.");
        RefreshRun.SetRange(Source, RefreshRun.Source::MFGCalculation);
        Assert.RecordCount(RefreshRun, 1);
        RefreshRun.FindFirst();
        Change.SetRange("Run No.", RefreshRun."Run No.");
        Change.SetRange("Field No.", ProdOrderComponent.FieldNo("Quantity per"));
        Assert.RecordCount(Change, 1);
    end;

    local procedure CreateRefreshedOrder(var ProductionOrder: Record "Production Order")
    var
        ComponentItem: Record Item;
        ParentItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        LibraryInventory.CreateItem(ComponentItem);
        LibraryInventory.CreateItem(ParentItem);
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItem."No.", 1);
        ParentItem.Validate("Replenishment System", ParentItem."Replenishment System"::"Prod. Order");
        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify(true);

        LibraryManufacturing.CreateProductionOrder(ProductionOrder, ProductionOrder.Status::"Firm Planned", ProductionOrder."Source Type"::Item, ParentItem."No.", 1);
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

    local procedure FindComponent(ProductionOrder: Record "Production Order"; var ProdOrderComponent: Record "Prod. Order Component")
    begin
        ProdOrderComponent.Reset();
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.FindFirst();
    end;

    local procedure AddComponentByHand(ProductionOrder: Record "Production Order"; ItemNo: Code[20]; QuantityPer: Decimal)
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.FindFirst();
        LibraryManufacturing.CreateProductionOrderComponent(ProdOrderComponent, ProductionOrder.Status, ProductionOrder."No.", ProdOrderLine."Line No.");
        ProdOrderComponent.Validate("Item No.", ItemNo);
        ProdOrderComponent.Validate("Quantity per", QuantityPer);
        ProdOrderComponent.Modify(true);
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Refresh Setup";
        FeatureSetup: Codeunit "MFG Refresh Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Notify on Changes" := false;
        Setup.Modify(true);
    end;
}
