namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.StandardCost;
using Microsoft.Pricing.Asset;
using Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Source;

codeunit 85307 "MFG Drift Price List" implements "MFG IDriftSource"
{
    Access = Public;

    var
        DescriptionLbl: Label 'Compares the standard cost of every purchased standard-cost item with its current purchase price list price: the price of its own vendor when there is one, otherwise the lowest. It takes precedence over the last purchase price, because it is what the item will cost from now on.';

    /// <summary>
    /// Adds or replaces one candidate per purchased standard-cost item with an active purchase price valid on the
    /// work date, proposing that price per base unit of measure. A candidate the last purchase price source added
    /// for the same item is replaced.
    /// </summary>
    /// <param name="TempDriftLine">The candidate buffer to add lines to.</param>
    procedure Collect(var TempDriftLine: Record "MFG Cost Drift Line" temporary)
    var
        Item: Record Item;
        Price: Decimal;
    begin
        Item.SetLoadFields("No.", Description, "Replenishment System", "Standard Cost", "Last Unit Cost Calc. Date", "Vendor No.", "Base Unit of Measure");
        Item.SetRange("Costing Method", Item."Costing Method"::Standard);
        Item.SetRange("Replenishment System", Item."Replenishment System"::Purchase);
        if not Item.FindSet() then
            exit;

        repeat
            if CurrentPrice(Item, Price) then
                if TempDriftLine.Get(Item."No.") then
                    ReplaceLastPurchasePrice(TempDriftLine, Price)
                else
                    AddCandidate(TempDriftLine, Item, Price);
        until Item.Next() = 0;
    end;

    /// <summary>
    /// Writes the item to the standard cost worksheet with the price list price as its new standard cost.
    /// </summary>
    /// <param name="DriftLine">The drift line.</param>
    /// <param name="WorksheetName">The standard cost worksheet to write to.</param>
    procedure TransferToWorksheet(DriftLine: Record "MFG Cost Drift Line"; WorksheetName: Code[10])
    var
        StandardCostWorksheet: Record "Standard Cost Worksheet";
    begin
        StandardCostWorksheet.Init();
        StandardCostWorksheet.Validate("Standard Cost Worksheet Name", WorksheetName);
        StandardCostWorksheet.Validate(Type, StandardCostWorksheet.Type::Item);
        StandardCostWorksheet.Validate("No.", DriftLine."Item No.");
        StandardCostWorksheet.Validate("New Standard Cost", DriftLine."Proposed Standard Cost");
        if not StandardCostWorksheet.Insert(true) then
            StandardCostWorksheet.Modify(true);
    end;

    /// <summary>
    /// Describes the source.
    /// </summary>
    /// <returns>The description.</returns>
    procedure Description(): Text
    begin
        exit(DescriptionLbl);
    end;

    local procedure ReplaceLastPurchasePrice(var TempDriftLine: Record "MFG Cost Drift Line" temporary; Price: Decimal)
    begin
        if TempDriftLine.Source <> TempDriftLine.Source::MFGPurchasePrice then
            exit;
        TempDriftLine.Source := TempDriftLine.Source::MFGPriceList;
        TempDriftLine."Proposed Standard Cost" := Price;
        TempDriftLine.Modify();
    end;

    local procedure AddCandidate(var TempDriftLine: Record "MFG Cost Drift Line" temporary; Item: Record Item; Price: Decimal)
    begin
        TempDriftLine.Init();
        TempDriftLine."Item No." := Item."No.";
        TempDriftLine.Source := TempDriftLine.Source::MFGPriceList;
        TempDriftLine.Description := Item.Description;
        TempDriftLine."Replenishment System" := Item."Replenishment System";
        TempDriftLine."Current Standard Cost" := Item."Standard Cost";
        TempDriftLine."Proposed Standard Cost" := Price;
        TempDriftLine."Last Unit Cost Calc. Date" := Item."Last Unit Cost Calc. Date";
        TempDriftLine.Insert();
    end;

    /// <summary>
    /// Finds the item's purchase price valid on the work date: active, in local currency, for any quantity, without a
    /// variant, not a discount line. The price of the item's own vendor wins; otherwise the lowest price per base
    /// unit of measure.
    /// </summary>
    local procedure CurrentPrice(Item: Record Item; var Price: Decimal): Boolean
    var
        PriceListLine: Record "Price List Line";
        LinePrice: Decimal;
        Found: Boolean;
        VendorFound: Boolean;
    begin
        PriceListLine.SetRange("Price Type", "Price Type"::Purchase);
        PriceListLine.SetRange("Asset Type", "Price Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", Item."No.");
        PriceListLine.SetRange(Status, "Price Status"::Active);
        PriceListLine.SetRange("Currency Code", '');
        PriceListLine.SetRange("Variant Code", '');
        PriceListLine.SetFilter("Minimum Quantity", '<=%1', 1);
        PriceListLine.SetFilter("Amount Type", '<>%1', "Price Amount Type"::Discount);
        PriceListLine.SetFilter("Starting Date", '..%1', WorkDate());
        PriceListLine.SetFilter("Ending Date", '%1|%2..', 0D, WorkDate());
        PriceListLine.SetFilter("Direct Unit Cost", '>0');
        if not PriceListLine.FindSet() then
            exit(false);

        repeat
            if PricePerBaseUnit(Item, PriceListLine, LinePrice) then
                if (PriceListLine."Source Type" = "Price Source Type"::Vendor) and (Item."Vendor No." <> '') and
                   (PriceListLine."Source No." = Item."Vendor No.")
                then begin
                    if not VendorFound or (LinePrice < Price) then
                        Price := LinePrice;
                    VendorFound := true;
                    Found := true;
                end else
                    if not VendorFound and (not Found or (LinePrice < Price)) then begin
                        Price := LinePrice;
                        Found := true;
                    end;
        until PriceListLine.Next() = 0;
        exit(Found);
    end;

    local procedure PricePerBaseUnit(Item: Record Item; PriceListLine: Record "Price List Line"; var LinePrice: Decimal): Boolean
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (PriceListLine."Unit of Measure Code" = '') or (PriceListLine."Unit of Measure Code" = Item."Base Unit of Measure") then begin
            LinePrice := PriceListLine."Direct Unit Cost";
            exit(true);
        end;
        if not ItemUnitOfMeasure.Get(Item."No.", PriceListLine."Unit of Measure Code") then
            exit(false);
        if ItemUnitOfMeasure."Qty. per Unit of Measure" = 0 then
            exit(false);
        LinePrice := Round(PriceListLine."Direct Unit Cost" / ItemUnitOfMeasure."Qty. per Unit of Measure", 0.00001);
        exit(true);
    end;
}
