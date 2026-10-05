namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;

codeunit 85213 "MFG WIP GL Source" implements "MFG IGLWipSource"
{
    Access = Public;

    /// <summary>
    /// Sums the general ledger entries on the WIP accounts of the inventory posting setup that were posted from the
    /// order's value entries, through the G/L - Item Ledger Relation.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    /// <returns>The net amount posted to WIP accounts for the order.</returns>
    procedure GLWipAmount(ProductionOrder: Record "Production Order"): Decimal
    var
        ValueEntry: Record "Value Entry";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GLEntry: Record "G/L Entry";
        WipAccounts: List of [Code[20]];
        Amount: Decimal;
    begin
        CollectWipAccounts(WipAccounts);
        if WipAccounts.Count() = 0 then
            exit(0);

        ValueEntry.SetLoadFields("Entry No.");
        FilterValueEntries(ValueEntry, ProductionOrder);
        if not ValueEntry.FindSet() then
            exit(0);

        GLEntry.SetLoadFields("G/L Account No.", Amount);
        repeat
            GLItemLedgerRelation.SetRange("Value Entry No.", ValueEntry."Entry No.");
            if GLItemLedgerRelation.FindSet() then
                repeat
                    if GLEntry.Get(GLItemLedgerRelation."G/L Entry No.") then
                        if WipAccounts.Contains(GLEntry."G/L Account No.") then
                            Amount += GLEntry.Amount;
                until GLItemLedgerRelation.Next() = 0;
        until ValueEntry.Next() = 0;
        exit(Amount);
    end;

    /// <summary>
    /// Sums, over the order's value entries, the actual cost minus the cost already posted to the general ledger.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    /// <returns>The actual cost not yet posted to the general ledger.</returns>
    procedure UnpostedCost(ProductionOrder: Record "Production Order"): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        FilterValueEntries(ValueEntry, ProductionOrder);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Posted to G/L");
        exit(ValueEntry."Cost Amount (Actual)" - ValueEntry."Cost Posted to G/L");
    end;

    local procedure FilterValueEntries(var ValueEntry: Record "Value Entry"; ProductionOrder: Record "Production Order")
    begin
        ValueEntry.SetRange("Order Type", "Inventory Order Type"::Production);
        ValueEntry.SetRange("Order No.", ProductionOrder."No.");
    end;

    local procedure CollectWipAccounts(var WipAccounts: List of [Code[20]])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.SetLoadFields("WIP Account");
        InventoryPostingSetup.SetFilter("WIP Account", '<>%1', '');
        if not InventoryPostingSetup.FindSet() then
            exit;
        repeat
            if not WipAccounts.Contains(InventoryPostingSetup."WIP Account") then
                WipAccounts.Add(InventoryPostingSetup."WIP Account");
        until InventoryPostingSetup.Next() = 0;
    end;
}
