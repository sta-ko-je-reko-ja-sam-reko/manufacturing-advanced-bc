namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.StandardCost;

codeunit 85304 "MFG Drift Roll-up" implements "MFG IDriftSource"
{
    Access = Public;

    var
        DescriptionLbl: Label 'Rolls up the standard cost of every manufactured or assembled standard-cost item from its current production BOM, routing, work and machine centre costs and the standard costs of its components, exactly as Roll Up Standard Cost does, and compares the result with the standard cost on the item card.';

    /// <summary>
    /// Rolls up every standard-cost item replenished by production order or assembly with the standard
    /// Calculate Standard Cost, without changing any item, and adds one candidate per item.
    /// </summary>
    /// <param name="TempDriftLine">The candidate buffer to add lines to.</param>
    procedure Collect(var TempDriftLine: Record "MFG Cost Drift Line" temporary)
    var
        Item: Record Item;
        TempItem: Record Item temporary;
    begin
        Item.SetRange("Costing Method", Item."Costing Method"::Standard);
        Item.SetFilter("Replenishment System", '%1|%2', Item."Replenishment System"::"Prod. Order", Item."Replenishment System"::Assembly);
        if Item.IsEmpty() then
            exit;

        RollUp(Item, TempItem);
        TempItem.SetRange("Costing Method", TempItem."Costing Method"::Standard);
        TempItem.SetFilter("Replenishment System", '%1|%2', TempItem."Replenishment System"::"Prod. Order", TempItem."Replenishment System"::Assembly);
        if not TempItem.FindSet() then
            exit;

        repeat
            Item.Get(TempItem."No.");
            TempDriftLine.Init();
            TempDriftLine."Item No." := Item."No.";
            TempDriftLine.Source := TempDriftLine.Source::MFGRollUp;
            TempDriftLine.Description := Item.Description;
            TempDriftLine."Replenishment System" := Item."Replenishment System";
            TempDriftLine."Current Standard Cost" := Item."Standard Cost";
            TempDriftLine."Proposed Standard Cost" := TempItem."Standard Cost";
            TempDriftLine."Last Unit Cost Calc. Date" := Item."Last Unit Cost Calc. Date";
            if TempDriftLine.Insert() then;
        until TempItem.Next() = 0;
    end;

    /// <summary>
    /// Rolls up the item again and writes it to the standard cost worksheet with every single-level and
    /// rolled-up cost share, the same way Roll Up Standard Cost does.
    /// </summary>
    /// <param name="DriftLine">The drift line.</param>
    /// <param name="WorksheetName">The standard cost worksheet to write to.</param>
    procedure TransferToWorksheet(DriftLine: Record "MFG Cost Drift Line"; WorksheetName: Code[10])
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        StandardCostWorksheet: Record "Standard Cost Worksheet";
        Found: Boolean;
    begin
        Item.SetRange("No.", DriftLine."Item No.");
        RollUp(Item, TempItem);
        TempItem.Get(DriftLine."Item No.");

        Found := StandardCostWorksheet.Get(WorksheetName, StandardCostWorksheet.Type::Item, TempItem."No.");
        StandardCostWorksheet.Validate("Standard Cost Worksheet Name", WorksheetName);
        StandardCostWorksheet.Validate(Type, StandardCostWorksheet.Type::Item);
        StandardCostWorksheet.Validate("No.", TempItem."No.");
        StandardCostWorksheet."New Standard Cost" := TempItem."Standard Cost";
        StandardCostWorksheet."New Single-Lvl Material Cost" := TempItem."Single-Level Material Cost";
        StandardCostWorksheet."New Single-Lvl Cap. Cost" := TempItem."Single-Level Capacity Cost";
        StandardCostWorksheet."New Single-Lvl Subcontrd Cost" := TempItem."Single-Level Subcontrd. Cost";
        StandardCostWorksheet."New Single-Lvl Cap. Ovhd Cost" := TempItem."Single-Level Cap. Ovhd Cost";
        StandardCostWorksheet."New Single-Lvl Mfg. Ovhd Cost" := TempItem."Single-Level Mfg. Ovhd Cost";
        StandardCostWorksheet."New Rolled-up Material Cost" := TempItem."Rolled-up Material Cost";
        StandardCostWorksheet."New Rolled-up Cap. Cost" := TempItem."Rolled-up Capacity Cost";
        StandardCostWorksheet."New Rolled-up Subcontrd Cost" := TempItem."Rolled-up Subcontracted Cost";
        StandardCostWorksheet."New Rolled-up Cap. Ovhd Cost" := TempItem."Rolled-up Cap. Overhead Cost";
        StandardCostWorksheet."New Rolled-up Mfg. Ovhd Cost" := TempItem."Rolled-up Mfg. Ovhd Cost";
        if Found then
            StandardCostWorksheet.Modify(true)
        else
            StandardCostWorksheet.Insert(true);
    end;

    /// <summary>
    /// Describes the source.
    /// </summary>
    /// <returns>The description.</returns>
    procedure Description(): Text
    begin
        exit(DescriptionLbl);
    end;

    local procedure RollUp(var Item: Record Item; var TempItem: Record Item temporary)
    var
        CalculateStandardCost: Codeunit "Calculate Standard Cost";
    begin
        CalculateStandardCost.SetProperties(WorkDate(), true, false, false, '', false);
        CalculateStandardCost.CalcItems(Item, TempItem);
    end;
}
