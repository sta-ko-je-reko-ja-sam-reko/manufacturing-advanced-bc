namespace ManufacturingAdvanced.Preflight;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;

codeunit 85111 "MFG Check Flushing Tracking" implements "MFG IPreflightCheck"
{
    Access = Public;

    var
        DescriptionLbl: Label 'A lot- or serial-tracked component is flushed automatically (forward or backward), but lot or serial numbers are not assigned for its whole remaining quantity, so the flushing fails when it posts.';
        FindingLbl: Label 'Component %1 is flushed %2 and needs item tracking, but lot or serial numbers are assigned for %3 of %4. Assign item tracking on the component line before the order is released.', Comment = '%1 = the component item number, %2 = the flushing method, %3 = the quantity with tracking assigned, %4 = the remaining quantity';

    /// <summary>
    /// Reports every automatically flushed, tracked component whose remaining quantity is not fully
    /// covered by assigned lot or serial numbers.
    /// </summary>
    /// <param name="ProductionOrder">The order to inspect.</param>
    /// <param name="Collector">Receives the findings.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        Assigned: Decimal;
    begin
        ProdOrderComponent.SetLoadFields("Item No.", "Location Code", "Flushing Method", "Remaining Qty. (Base)");
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetFilter("Flushing Method", '%1|%2|%3|%4',
            "Flushing Method"::Forward, "Flushing Method"::Backward, "Flushing Method"::"Pick + Forward", "Flushing Method"::"Pick + Backward");
        ProdOrderComponent.SetFilter("Remaining Qty. (Base)", '>0');
        if not ProdOrderComponent.FindSet() then
            exit;

        repeat
            if IsTracked(ProdOrderComponent."Item No.") then begin
                Assigned := AssignedQuantity(ProdOrderComponent);
                if Assigned < ProdOrderComponent."Remaining Qty. (Base)" then
                    Collector.Add(
                        ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Line No.", ProdOrderComponent."Item No.", ProdOrderComponent."Location Code",
                        StrSubstNo(FindingLbl, ProdOrderComponent."Item No.", ProdOrderComponent."Flushing Method", Assigned, ProdOrderComponent."Remaining Qty. (Base)"));
            end;
        until ProdOrderComponent.Next() = 0;
    end;

    /// <summary>
    /// A missing lot or serial number makes the flushing fail at posting, so it is an error by default.
    /// </summary>
    /// <returns>Error.</returns>
    procedure DefaultSeverity(): Enum "MFG Preflight Severity"
    begin
        exit(Enum::"MFG Preflight Severity"::MFGError);
    end;

    /// <summary>
    /// Describes the check.
    /// </summary>
    /// <returns>The description.</returns>
    procedure Description(): Text
    begin
        exit(DescriptionLbl);
    end;

    local procedure IsTracked(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        Item.SetLoadFields("Item Tracking Code");
        if not Item.Get(ItemNo) then
            exit(false);
        if Item."Item Tracking Code" = '' then
            exit(false);

        ItemTrackingCode.SetLoadFields("Lot Specific Tracking", "SN Specific Tracking", "Lot Manuf. Outbound Tracking", "SN Manuf. Outbound Tracking");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);

        exit(ItemTrackingCode."Lot Specific Tracking" or ItemTrackingCode."SN Specific Tracking" or
            ItemTrackingCode."Lot Manuf. Outbound Tracking" or ItemTrackingCode."SN Manuf. Outbound Tracking");
    end;

    local procedure AssignedQuantity(ProdOrderComponent: Record "Prod. Order Component"): Decimal
    var
        ReservationEntry: Record "Reservation Entry";
        Assigned: Decimal;
    begin
        ReservationEntry.SetRange("Source Type", Database::"Prod. Order Component");
        ReservationEntry.SetRange("Source Subtype", ProdOrderComponent.Status.AsInteger());
        ReservationEntry.SetRange("Source ID", ProdOrderComponent."Prod. Order No.");
        ReservationEntry.SetRange("Source Prod. Order Line", ProdOrderComponent."Prod. Order Line No.");
        ReservationEntry.SetRange("Source Ref. No.", ProdOrderComponent."Line No.");

        ReservationEntry.SetFilter("Lot No.", '<>%1', '');
        ReservationEntry.CalcSums("Quantity (Base)");
        Assigned := Abs(ReservationEntry."Quantity (Base)");

        ReservationEntry.SetRange("Lot No.", '');
        ReservationEntry.SetFilter("Serial No.", '<>%1', '');
        ReservationEntry.CalcSums("Quantity (Base)");
        exit(Assigned + Abs(ReservationEntry."Quantity (Base)"));
    end;
}
