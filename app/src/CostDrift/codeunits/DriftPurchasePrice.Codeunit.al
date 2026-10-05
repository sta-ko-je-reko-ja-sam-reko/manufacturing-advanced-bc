namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.StandardCost;

codeunit 85305 "MFG Drift Purchase Price" implements "MFG IDriftSource"
{
    Access = Public;

    var
        DescriptionLbl: Label 'Compares the standard cost of every purchased standard-cost item with the last direct cost it was bought at. A purchased component whose standard is stale makes every roll-up above it stale too.';

    /// <summary>
    /// Adds one candidate per purchased standard-cost item that has been bought, proposing its last direct
    /// cost.
    /// </summary>
    /// <param name="TempDriftLine">The candidate buffer to add lines to.</param>
    procedure Collect(var TempDriftLine: Record "MFG Cost Drift Line" temporary)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.", Description, "Replenishment System", "Standard Cost", "Last Direct Cost", "Last Unit Cost Calc. Date");
        Item.SetRange("Costing Method", Item."Costing Method"::Standard);
        Item.SetRange("Replenishment System", Item."Replenishment System"::Purchase);
        Item.SetFilter("Last Direct Cost", '>0');
        if not Item.FindSet() then
            exit;

        repeat
            TempDriftLine.Init();
            TempDriftLine."Item No." := Item."No.";
            TempDriftLine.Source := TempDriftLine.Source::MFGPurchasePrice;
            TempDriftLine.Description := Item.Description;
            TempDriftLine."Replenishment System" := Item."Replenishment System";
            TempDriftLine."Current Standard Cost" := Item."Standard Cost";
            TempDriftLine."Proposed Standard Cost" := Item."Last Direct Cost";
            TempDriftLine."Last Unit Cost Calc. Date" := Item."Last Unit Cost Calc. Date";
            if TempDriftLine.Insert() then;
        until Item.Next() = 0;
    end;

    /// <summary>
    /// Writes the item to the standard cost worksheet with the last direct cost as its new standard cost, the
    /// same way Suggest Item Standard Cost writes a purchased item.
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
}
