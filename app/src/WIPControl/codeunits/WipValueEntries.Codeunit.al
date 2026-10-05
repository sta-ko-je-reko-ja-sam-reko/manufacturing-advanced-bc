namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;

codeunit 85204 "MFG WIP Value Entries" implements "MFG IWipValuation"
{
    Access = Public;

    /// <summary>
    /// Values an order's work in progress from its value entries: the cost of what it consumed plus the
    /// cost of the capacity posted on it, minus the cost at which its output has been valued so far, actual
    /// and expected. Also finds the posting date of its last output.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    /// <param name="Proposal">The proposal whose cost, WIP and last output fields are set.</param>
    procedure Calculate(ProductionOrder: Record "Production Order"; var Proposal: Record "MFG Finish Proposal")
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Order Type", "Inventory Order Type"::Production);
        ValueEntry.SetRange("Order No.", ProductionOrder."No.");

        Proposal."Consumption Cost" := -SumCost(ValueEntry, "Item Ledger Entry Type"::Consumption);
        Proposal."Capacity Cost" := SumCost(ValueEntry, "Item Ledger Entry Type"::" ");
        Proposal."Output Cost" := SumCost(ValueEntry, "Item Ledger Entry Type"::Output);
        Proposal."Est. WIP Amount" := Proposal."Consumption Cost" + Proposal."Capacity Cost" - Proposal."Output Cost";
        Proposal."Last Output Date" := LastOutputDate(ValueEntry);
    end;

    local procedure SumCost(var ValueEntry: Record "Value Entry"; EntryType: Enum "Item Ledger Entry Type"): Decimal
    begin
        ValueEntry.SetRange("Item Ledger Entry Type", EntryType);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
        exit(ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)");
    end;

    local procedure LastOutputDate(var ValueEntry: Record "Value Entry"): Date
    var
        LastDate: Date;
    begin
        LastDate := 0D;
        ValueEntry.SetRange("Item Ledger Entry Type", "Item Ledger Entry Type"::Output);
        ValueEntry.SetLoadFields("Posting Date");
        if not ValueEntry.FindSet() then
            exit(0D);

        repeat
            if ValueEntry."Posting Date" > LastDate then
                LastDate := ValueEntry."Posting Date";
        until ValueEntry.Next() = 0;
        exit(LastDate);
    end;
}
