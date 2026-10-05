namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Posting;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;

codeunit 85603 "MFG Shop Floor Journal Posting" implements "MFG IShopFloorPosting"
{
    Access = Public;

    /// <summary>
    /// Posts an event through the standard Item Jnl.-Post Line with an output journal line built the way the
    /// standard Production Journal builds one: output and scrap quantities with the scrap code, run time
    /// converted from minutes into the operation's capacity unit of measure, or stop time with the stop code.
    /// </summary>
    /// <param name="ShopFloorEvent">The event to post.</param>
    procedure Post(ShopFloorEvent: Record "MFG Shop Floor Event")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ProdOrderLine.Get(ProdOrderLine.Status::Released, ShopFloorEvent."Prod. Order No.", ShopFloorEvent."Prod. Order Line No.");

        ItemJournalLine.Init();
        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Output);
        ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.Validate("Order No.", ProdOrderLine."Prod. Order No.");
        ItemJournalLine.Validate("Order Line No.", ProdOrderLine."Line No.");
        ItemJournalLine.Validate("Item No.", ProdOrderLine."Item No.");
        ItemJournalLine.Validate("Variant Code", ProdOrderLine."Variant Code");
        ItemJournalLine.Validate("Location Code", ProdOrderLine."Location Code");
        if ProdOrderLine."Bin Code" <> '' then
            ItemJournalLine.Validate("Bin Code", ProdOrderLine."Bin Code");
        ItemJournalLine."Document No." := ProdOrderLine."Prod. Order No.";
        if ShopFloorEvent."Operation No." <> '' then
            ItemJournalLine.Validate("Operation No.", ShopFloorEvent."Operation No.");

        case ShopFloorEvent."Event Type" of
            ShopFloorEvent."Event Type"::MFGOutput:
                FillOutput(ItemJournalLine, ShopFloorEvent);
            ShopFloorEvent."Event Type"::MFGDowntime:
                FillDowntime(ItemJournalLine, ShopFloorEvent);
        end;

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
    end;

    local procedure FillOutput(var ItemJournalLine: Record "Item Journal Line"; ShopFloorEvent: Record "MFG Shop Floor Event")
    begin
        ItemJournalLine.Validate("Output Quantity", ShopFloorEvent."Output Quantity");
        if ShopFloorEvent."Scrap Quantity" <> 0 then begin
            ItemJournalLine.Validate("Scrap Quantity", ShopFloorEvent."Scrap Quantity");
            if ShopFloorEvent."Scrap Code" <> '' then
                ItemJournalLine.Validate("Scrap Code", ShopFloorEvent."Scrap Code");
        end;
        if (ShopFloorEvent."Run Minutes" <> 0) and (ItemJournalLine."Operation No." <> '') then
            ItemJournalLine.Validate("Run Time", ToCapacityUnit(ItemJournalLine, ShopFloorEvent."Run Minutes"));
    end;

    local procedure FillDowntime(var ItemJournalLine: Record "Item Journal Line"; ShopFloorEvent: Record "MFG Shop Floor Event")
    begin
        ItemJournalLine.Validate("Output Quantity", 0);
        ItemJournalLine.Validate("Stop Time", ToCapacityUnit(ItemJournalLine, ShopFloorEvent."Stop Minutes"));
        if ShopFloorEvent."Stop Code" <> '' then
            ItemJournalLine.Validate("Stop Code", ShopFloorEvent."Stop Code");
    end;

    local procedure ToCapacityUnit(ItemJournalLine: Record "Item Journal Line"; Minutes: Decimal): Decimal
    var
        ShopCalendarManagement: Codeunit "Shop Calendar Management";
        Factor: Decimal;
    begin
        if ItemJournalLine."Cap. Unit of Measure Code" = '' then
            exit(Minutes);
        Factor := ShopCalendarManagement.TimeFactor(ItemJournalLine."Cap. Unit of Measure Code");
        if Factor = 0 then
            exit(Minutes);
        exit(Round(Minutes * 60000 / Factor, 0.00001));
    end;
}
