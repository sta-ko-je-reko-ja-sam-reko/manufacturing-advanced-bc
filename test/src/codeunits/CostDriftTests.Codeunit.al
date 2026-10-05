namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.CostDrift;
using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.StandardCost;
using Microsoft.Pricing.Asset;
using Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Source;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89009 "MFG Cost Drift Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure APurchasePriceBeyondTheToleranceIsListed()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] A purchased standard-cost item with standard 10, last bought at 12, and a 2 % tolerance
        PrepareSetup(2);
        CreatePurchasedItem('MFGD-PUR1', 10, 12);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] It is listed with a drift of 2, or 20 %, from the purchase price source
        DriftLine.Get('MFGD-PUR1');
        Assert.AreEqual(DriftLine.Source::MFGPurchasePrice, DriftLine.Source, 'The purchase price proposes the cost.');
        Assert.AreEqual(12, DriftLine."Proposed Standard Cost", 'The proposal is the last direct cost.');
        Assert.AreEqual(2, DriftLine."Drift Amount", 'Drift is proposed minus current.');
        Assert.AreEqual(20, DriftLine."Drift %", 'Drift % is relative to the current standard.');
    end;

    [Test]
    procedure ADriftWithinTheToleranceIsNotListed()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] A purchased standard-cost item 1 % off its standard, and a 2 % tolerance
        PrepareSetup(2);
        CreatePurchasedItem('MFGD-PUR2', 10, 10.1);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] It is not listed
        Assert.IsFalse(DriftLine.Get('MFGD-PUR2'), 'A drift within the tolerance is not listed.');
    end;

    [Test]
    procedure AnInactiveSourceIsNotUsed()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] The purchase price source is inactive, and an item 20 % off its standard
        PrepareSetup(2);
        SetSourceActive(Enum::"MFG Drift Source Type"::MFGPurchasePrice, false);
        CreatePurchasedItem('MFGD-PUR3', 10, 12);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] It is not listed
        Assert.IsFalse(DriftLine.Get('MFGD-PUR3'), 'An inactive source proposes nothing.');
        SetSourceActive(Enum::"MFG Drift Source Type"::MFGPurchasePrice, true);
    end;

    [Test]
    procedure SendingALineWritesTheWorksheet()
    var
        DriftLine: Record "MFG Cost Drift Line";
        StandardCostWorksheet: Record "Standard Cost Worksheet";
        Setup: Record "MFG Cost Drift Setup";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] The feature is on and a purchased item has drifted to 12
        PrepareSetup(2);
        SetFeature(true);
        CreatePurchasedItem('MFGD-PUR4', 10, 12);
        Engine.Calculate();

        // [WHEN] Its line is selected and sent to the worksheet
        DriftLine.Get('MFGD-PUR4');
        DriftLine.Selected := true;
        DriftLine.Modify(true);
        Assert.AreEqual(1, Engine.TransferSelected(), 'One line should be sent.');

        // [THEN] The worksheet named in the setup has the item with a new standard cost of 12, and the line is marked sent
        Setup.Get();
        StandardCostWorksheet.Get(Setup."Worksheet Name", StandardCostWorksheet.Type::Item, 'MFGD-PUR4');
        Assert.AreEqual(12, StandardCostWorksheet."New Standard Cost", 'The new standard cost is the proposal.');
        DriftLine.Get('MFGD-PUR4');
        Assert.IsTrue(DriftLine.Transferred, 'The line should be marked as sent.');
    end;

    [Test]
    procedure SendingIsRefusedWhileTheFeatureIsOff()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] The feature is off and a purchased item has drifted
        PrepareSetup(2);
        SetFeature(false);
        CreatePurchasedItem('MFGD-PUR5', 10, 12);
        Engine.Calculate();

        // [WHEN] Its line is sent to the worksheet
        DriftLine.Get('MFGD-PUR5');
        asserterror Engine.TransferLine(DriftLine);

        // [THEN] It is refused
        Assert.ExpectedError('is not enabled');
    end;

    [Test]
    procedure OrderVariancesAreSummedByType()
    var
        ProductionOrder: Record "Production Order";
        OrderVariance: Record "MFG Order Variance";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] An order finished on the work date, output valued at 100, with a material variance of 5 and a capacity variance of -2
        PrepareSetup(2);
        CreateFinishedOrder(ProductionOrder, 'MFGD-FIN1');
        AddValueEntry(ProductionOrder."No.", "Cost Entry Type"::"Direct Cost", "Cost Variance Type"::" ", 100);
        AddValueEntry(ProductionOrder."No.", "Cost Entry Type"::Variance, "Cost Variance Type"::Material, 5);
        AddValueEntry(ProductionOrder."No.", "Cost Entry Type"::Variance, "Cost Variance Type"::Capacity, -2);

        // [WHEN] The variances are calculated
        Engine.CalculateVariances();

        // [THEN] The order shows each type, a total of 3, which is 3 % of the output cost
        OrderVariance.Get(ProductionOrder."No.");
        Assert.AreEqual(100, OrderVariance."Output Cost", 'The output cost excludes the variances.');
        Assert.AreEqual(5, OrderVariance."Material Variance", 'Material variance.');
        Assert.AreEqual(-2, OrderVariance."Capacity Variance", 'Capacity variance.');
        Assert.AreEqual(3, OrderVariance."Total Variance", 'Total variance.');
        Assert.AreEqual(3, OrderVariance."Variance %", 'Variance % of the output cost.');
    end;

    [Test]
    procedure EnsureSourcesKeepsTheUsersChoice()
    var
        DriftSource: Record "MFG Drift Source";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] The sources exist and the user switched one off
        Engine.EnsureSources();
        SetSourceActive(Enum::"MFG Drift Source Type"::MFGRollUp, false);

        // [WHEN] They are ensured again
        Engine.EnsureSources();

        // [THEN] One row per source, and the user's choice survives
        Assert.RecordCount(DriftSource, 3);
        DriftSource.Get(DriftSource.Source::MFGRollUp);
        Assert.IsFalse(DriftSource.Active, 'EnsureSources must not overwrite the user''s choice.');
        SetSourceActive(Enum::"MFG Drift Source Type"::MFGRollUp, true);
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG Cost Drift Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] Step 50, with a toggle, opening the feature setup page
        TempSetupStep.FindFirst();
        Assert.AreEqual(50, TempSetupStep."Step No.", 'Standard cost drift comes after refresh protection.');
        Assert.IsTrue(TempSetupStep."Has Toggle", 'Standard cost drift can be switched on and off.');
        Assert.AreEqual(Page::"MFG Cost Drift Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure ImportingSampleDataTwiceCreatesItOnce()
    var
        DriftSource: Record "MFG Drift Source";
        ConfigPackage: Record "Config. Package";
        StandardCostWorksheetName: Record "Standard Cost Worksheet Name";
        Setup: Record "MFG Cost Drift Setup";
        DemoCostDrift: Codeunit "MFG Demo Cost Drift";
    begin
        // [WHEN] The sample data is imported twice
        DemoCostDrift.Import();
        DemoCostDrift.Import();

        // [THEN] The sources, the worksheet and the configuration package exist once
        Assert.RecordCount(DriftSource, 3);
        Setup.Get();
        Assert.IsTrue(StandardCostWorksheetName.Get(Setup."Worksheet Name"), 'The standard cost worksheet should exist.');
        Assert.IsTrue(ConfigPackage.Get('MFG-COSTDRIFT'), 'Importing sample data should build the configuration package.');
    end;

    [Test]
    procedure APriceListPriceReplacesTheLastPurchasePrice()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] A purchased standard-cost item with standard 10, last bought at 12, and an active purchase price of 15
        PrepareSetup(2);
        CreatePurchasedItem('MFGD-PL1', 10, 12);
        AddPurchasePrice('MFGD-PL1', '', '', 15, WorkDate() - 1, 0D, '', 0);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] The price list proposes the cost, not the last purchase
        DriftLine.Get('MFGD-PL1');
        Assert.AreEqual(DriftLine.Source::MFGPriceList, DriftLine.Source, 'A current price list takes precedence.');
        Assert.AreEqual(15, DriftLine."Proposed Standard Cost", 'The proposal is the price list price.');
    end;

    [Test]
    procedure TheItemsOwnVendorPriceWins()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] An item bought from vendor MFGD-V1 at 14 on its price list, and offered by MFGD-V2 at 11
        PrepareSetup(2);
        CreatePurchasedItem('MFGD-PL2', 10, 0);
        SetItemVendor('MFGD-PL2', 'MFGD-V1');
        AddPurchasePrice('MFGD-PL2', 'MFGD-V1', '', 14, WorkDate() - 1, 0D, '', 0);
        AddPurchasePrice('MFGD-PL2', 'MFGD-V2', '', 11, WorkDate() - 1, 0D, '', 0);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] The item's own vendor's price is proposed
        DriftLine.Get('MFGD-PL2');
        Assert.AreEqual(14, DriftLine."Proposed Standard Cost", 'The item''s own vendor price wins over a cheaper one.');
    end;

    [Test]
    procedure PricesThatDoNotApplyTodayAreIgnored()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] An item last bought at 12, with purchase prices starting tomorrow, in a foreign currency, and for a
        // minimum quantity of 10
        PrepareSetup(2);
        CreatePurchasedItem('MFGD-PL3', 10, 12);
        AddPurchasePrice('MFGD-PL3', '', '', 20, WorkDate() + 1, 0D, '', 0);
        AddPurchasePrice('MFGD-PL3', '', 'MFGD-FCY', 21, WorkDate() - 1, 0D, '', 0);
        AddPurchasePrice('MFGD-PL3', '', '', 22, WorkDate() - 1, 0D, '', 10);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] None of them applies, and the last purchase price stays the proposal
        DriftLine.Get('MFGD-PL3');
        Assert.AreEqual(DriftLine.Source::MFGPurchasePrice, DriftLine.Source, 'No price list price applies today.');
        Assert.AreEqual(12, DriftLine."Proposed Standard Cost", 'The last purchase price is proposed.');
    end;

    [Test]
    procedure APricePerBoxIsConvertedToTheBaseUnit()
    var
        DriftLine: Record "MFG Cost Drift Line";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        // [GIVEN] An item with standard 5, priced at 100 per box of 10
        PrepareSetup(2);
        CreatePurchasedItem('MFGD-PL4', 5, 0);
        AddUnitOfMeasure('MFGD-PL4', 'MFGD-BOX', 10);
        AddPurchasePrice('MFGD-PL4', '', '', 100, WorkDate() - 1, 0D, 'MFGD-BOX', 0);

        // [WHEN] The drift is calculated
        Engine.Calculate();

        // [THEN] The proposal is 10 per base unit
        DriftLine.Get('MFGD-PL4');
        Assert.AreEqual(10, DriftLine."Proposed Standard Cost", 'The box price is divided by the units in a box.');
    end;

    local procedure AddPurchasePrice(ItemNo: Code[20]; VendorNo: Code[20]; CurrencyCode: Code[10]; DirectUnitCost: Decimal; StartingDate: Date; EndingDate: Date; UnitOfMeasureCode: Code[10]; MinimumQuantity: Decimal)
    var
        PriceListLine: Record "Price List Line";
        LineNo: Integer;
    begin
        PriceListLine.SetRange("Price List Code", 'MFGD-PRICES');
        if PriceListLine.FindLast() then
            LineNo := PriceListLine."Line No.";
        PriceListLine.Init();
        PriceListLine."Price List Code" := 'MFGD-PRICES';
        PriceListLine."Line No." := LineNo + 10000;
        PriceListLine."Price Type" := "Price Type"::Purchase;
        PriceListLine."Amount Type" := "Price Amount Type"::Price;
        PriceListLine."Asset Type" := "Price Asset Type"::Item;
        PriceListLine."Asset No." := ItemNo;
        if VendorNo = '' then
            PriceListLine."Source Type" := "Price Source Type"::"All Vendors"
        else begin
            PriceListLine."Source Type" := "Price Source Type"::Vendor;
            PriceListLine."Source No." := VendorNo;
        end;
        PriceListLine."Currency Code" := CurrencyCode;
        PriceListLine."Starting Date" := StartingDate;
        PriceListLine."Ending Date" := EndingDate;
        PriceListLine."Unit of Measure Code" := UnitOfMeasureCode;
        PriceListLine."Minimum Quantity" := MinimumQuantity;
        PriceListLine."Direct Unit Cost" := DirectUnitCost;
        PriceListLine.Status := "Price Status"::Active;
        PriceListLine.Insert(false);
    end;

    local procedure SetItemVendor(ItemNo: Code[20]; VendorNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item."Vendor No." := VendorNo;
        Item.Modify(false);
    end;

    local procedure AddUnitOfMeasure(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; QtyPerUnit: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure."Item No." := ItemNo;
        ItemUnitOfMeasure.Code := UnitOfMeasureCode;
        ItemUnitOfMeasure."Qty. per Unit of Measure" := QtyPerUnit;
        if not ItemUnitOfMeasure.Insert(false) then
            ItemUnitOfMeasure.Modify(false);
    end;

    local procedure CreatePurchasedItem(ItemNo: Code[20]; StandardCost: Decimal; LastDirectCost: Decimal)
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            Item.Delete(false);
        Item.Init();
        Item."No." := ItemNo;
        Item."Costing Method" := Item."Costing Method"::Standard;
        Item."Replenishment System" := Item."Replenishment System"::Purchase;
        Item."Standard Cost" := StandardCost;
        Item."Last Direct Cost" := LastDirectCost;
        Item.Insert(false);
    end;

    local procedure CreateFinishedOrder(var ProductionOrder: Record "Production Order"; OrderNo: Code[20])
    begin
        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::Finished;
        ProductionOrder."No." := OrderNo;
        ProductionOrder."Source No." := 'MFGD-OUT';
        ProductionOrder."Finished Date" := WorkDate();
        ProductionOrder.Insert(false);
    end;

    local procedure AddValueEntry(OrderNo: Code[20]; EntryType: Enum "Cost Entry Type"; VarianceType: Enum "Cost Variance Type"; CostAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        EntryNo: Integer;
    begin
        if ValueEntry.FindLast() then
            EntryNo := ValueEntry."Entry No.";

        ValueEntry.Init();
        ValueEntry."Entry No." := EntryNo + 1;
        ValueEntry."Order Type" := "Inventory Order Type"::Production;
        ValueEntry."Order No." := OrderNo;
        ValueEntry."Item Ledger Entry Type" := "Item Ledger Entry Type"::Output;
        ValueEntry."Entry Type" := EntryType;
        ValueEntry."Variance Type" := VarianceType;
        ValueEntry."Cost Amount (Actual)" := CostAmount;
        ValueEntry."Posting Date" := WorkDate();
        ValueEntry.Insert(false);
    end;

    local procedure PrepareSetup(TolerancePct: Decimal)
    var
        Setup: Record "MFG Cost Drift Setup";
        FeatureSetup: Codeunit "MFG Cost Drift Feature Setup";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."Tolerance %" := TolerancePct;
        Setup."Variance Days" := 30;
        Setup.Modify(true);
        Engine.EnsureSources();
        SetSourceActive(Enum::"MFG Drift Source Type"::MFGRollUp, false);
    end;

    local procedure SetSourceActive(Source: Enum "MFG Drift Source Type"; Active: Boolean)
    var
        DriftSource: Record "MFG Drift Source";
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        Engine.EnsureSources();
        DriftSource.Get(Source);
        DriftSource.Active := Active;
        DriftSource.Modify(true);
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Cost Drift Setup";
        FeatureSetup: Codeunit "MFG Cost Drift Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup.Modify(true);
    end;
}
