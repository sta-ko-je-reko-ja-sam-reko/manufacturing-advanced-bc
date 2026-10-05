namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.ShopFloor;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using System.TestLibraries.Utilities;

codeunit 89015 "MFG Shop Floor Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";

    [Test]
    procedure ReportedOutputIsPostedToTheOrder()
    var
        ComponentItem: Record Item;
        ParentItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Locator: Codeunit "MFG Shop Floor Locator";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] The terminal is on with the standard posting, and a released order for 3 of an item without a routing
        Locator.ResetPosting();
        SetFeature(true);
        LibraryInventory.CreateItem(ComponentItem);
        LibraryInventory.CreateItem(ParentItem);
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItem."No.", 1);
        ParentItem.Validate("Replenishment System", ParentItem."Replenishment System"::"Prod. Order");
        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify(true);
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProductionOrder."Source Type"::Item, ParentItem."No.", 3);
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.FindFirst();

        // [WHEN] An operator reports 2 good from the order line
        Engine.ReportLineOutput(ProdOrderLine, 2, 0, '');

        // [THEN] An output entry of 2 is posted and the line's finished quantity is 2
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", ProductionOrder."No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        ItemLedgerEntry.FindFirst();
        Assert.AreEqual(2, ItemLedgerEntry.Quantity, 'The output entry carries the reported quantity.');
        ProdOrderLine.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No.");
        Assert.AreEqual(2, ProdOrderLine."Finished Quantity", 'The order line''s finished quantity follows the posting.');
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Shop Floor Setup";
        FeatureSetup: Codeunit "MFG Shop Floor Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup.Modify(true);
    end;
}
