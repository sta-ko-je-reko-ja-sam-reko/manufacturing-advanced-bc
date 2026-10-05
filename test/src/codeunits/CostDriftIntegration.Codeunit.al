namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.CostDrift;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.StandardCost;
using System.TestLibraries.Utilities;

codeunit 89010 "MFG Cost Drift Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";

    [Test]
    procedure AManufacturedItemWhoseRollUpMovedIsListedAndSentWithItsCostShares()
    var
        ComponentItem: Record Item;
        ParentItem: Record Item;
        DriftLine: Record "MFG Cost Drift Line";
        StandardCostWorksheet: Record "Standard Cost Worksheet";
        Setup: Record "MFG Cost Drift Setup";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] A standard-cost item made of two of a component whose standard cost is 10, with its own standard still at 15
        PrepareFeature();
        CreateStandardItem(ComponentItem, ComponentItem."Replenishment System"::Purchase, 10);
        CreateStandardItem(ParentItem, ParentItem."Replenishment System"::"Prod. Order", 15);
        AttachBom(ParentItem, ComponentItem."No.", 2);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] The roll-up proposes 20
        DriftLine.Get(ParentItem."No.");
        Assert.AreEqual(DriftLine.Source::MFGRollUp, DriftLine.Source, 'The roll-up proposes the cost of a manufactured item.');
        Assert.AreEqual(20, DriftLine."Proposed Standard Cost", 'Two components at 10 roll up to 20.');

        // [WHEN] It is sent to the worksheet
        Engine.TransferLine(DriftLine);

        // [THEN] The worksheet line carries the new cost and its material share, as Roll Up Standard Cost would write it
        Setup.Get();
        StandardCostWorksheet.Get(Setup."Worksheet Name", StandardCostWorksheet.Type::Item, ParentItem."No.");
        Assert.AreEqual(20, StandardCostWorksheet."New Standard Cost", 'The new standard cost.');
        Assert.AreEqual(20, StandardCostWorksheet."New Single-Lvl Material Cost", 'The single-level material share.');
        Assert.AreEqual(20, StandardCostWorksheet."New Rolled-up Material Cost", 'The rolled-up material share.');
    end;

    local procedure CreateStandardItem(var Item: Record Item; ReplenishmentSystem: Enum "Replenishment System"; StandardCost: Decimal)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Costing Method", Item."Costing Method"::Standard);
        Item.Validate("Replenishment System", ReplenishmentSystem);
        Item.Validate("Standard Cost", StandardCost);
        Item.Modify(true);
    end;

    local procedure AttachBom(var ParentItem: Record Item; ComponentItemNo: Code[20]; QuantityPer: Decimal)
    var
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItemNo, QuantityPer);
        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify(true);
    end;

    local procedure PrepareFeature()
    var
        Setup: Record "MFG Cost Drift Setup";
        DriftSource: Record "MFG Drift Source";
        FeatureSetup: Codeunit "MFG Cost Drift Feature Setup";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := true;
        Setup."Tolerance %" := 2;
        Setup.Modify(true);
        Engine.EnsureSources();
        DriftSource.ModifyAll(Active, true, true);
    end;
}
