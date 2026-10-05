namespace ManufacturingAdvanced.Preflight;

using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;

codeunit 85114 "MFG Check Flushing Whse." implements "MFG IPreflightCheck"
{
    Access = Public;

    var
        TempLocation: Record Location temporary;
        DescriptionLbl: Label 'A component''s flushing method does not fit the warehouse handling of its location: a pick method where nothing is picked, Pick + Forward without a routing link, which is never picked, or automatic flushing at a location where picks are mandatory, which consumes from the production bin without a pick.';
        NoHandlingLbl: Label 'Component %1 is flushed %2, but location %3 has no warehouse handling for production consumption, so no pick is created for it. Use a flushing method without Pick, or set up warehouse handling on the location.', Comment = '%1 = the component item number, %2 = the flushing method, %3 = the location code';
        ForwardNoLinkLbl: Label 'Component %1 is flushed Pick + Forward but has no routing link code, so Business Central creates no pick for it and flushes it when the order is released, from a bin nothing was picked to. Give it a routing link code, or use Pick + Manual or Pick + Backward.', Comment = '%1 = the component item number';
        MandatoryPickLbl: Label 'Component %1 is flushed %2 at location %3, where warehouse picks are mandatory for production. No pick is created for it, so it is consumed from the production bin only if something else, such as a movement, has put it there. Use Pick + Forward or Pick + Backward to have it picked.', Comment = '%1 = the component item number, %2 = the flushing method, %3 = the location code';

    /// <summary>
    /// Reports every component with remaining quantity whose flushing method conflicts with the warehouse
    /// handling of its location.
    /// </summary>
    /// <param name="ProductionOrder">The order to inspect.</param>
    /// <param name="Collector">Receives the findings.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        MessageText: Text;
    begin
        ProdOrderComponent.SetLoadFields("Item No.", "Location Code", "Flushing Method", "Routing Link Code", "Remaining Qty. (Base)");
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetFilter("Remaining Qty. (Base)", '>0');
        if not ProdOrderComponent.FindSet() then
            exit;

        repeat
            MessageText := Conflict(ProdOrderComponent);
            if MessageText <> '' then
                Collector.Add(
                    ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Line No.", ProdOrderComponent."Item No.", ProdOrderComponent."Location Code",
                    MessageText);
        until ProdOrderComponent.Next() = 0;
    end;

    /// <summary>
    /// The order can be released and posted, but components end up unpicked or consumed from an empty bin, so
    /// it is a warning by default.
    /// </summary>
    /// <returns>Warning.</returns>
    procedure DefaultSeverity(): Enum "MFG Preflight Severity"
    begin
        exit(Enum::"MFG Preflight Severity"::MFGWarning);
    end;

    /// <summary>
    /// Describes the check.
    /// </summary>
    /// <returns>The description.</returns>
    procedure Description(): Text
    begin
        exit(DescriptionLbl);
    end;

    local procedure Conflict(ProdOrderComponent: Record "Prod. Order Component"): Text
    var
        PickMethod: Boolean;
    begin
        GetLocation(ProdOrderComponent."Location Code");
        PickMethod := ProdOrderComponent."Flushing Method" in
            ["Flushing Method"::"Pick + Manual", "Flushing Method"::"Pick + Forward", "Flushing Method"::"Pick + Backward"];

        if PickMethod and (ProdOrderComponent."Location Code" <> '') and not HasPickHandling() then
            exit(StrSubstNo(NoHandlingLbl, ProdOrderComponent."Item No.", ProdOrderComponent."Flushing Method", ProdOrderComponent."Location Code"));

        if (ProdOrderComponent."Flushing Method" = "Flushing Method"::"Pick + Forward") and (ProdOrderComponent."Routing Link Code" = '') then
            exit(StrSubstNo(ForwardNoLinkLbl, ProdOrderComponent."Item No."));

        if (ProdOrderComponent."Flushing Method" in ["Flushing Method"::Forward, "Flushing Method"::Backward]) and
           (TempLocation."Prod. Consump. Whse. Handling" = "Prod. Consump. Whse. Handling"::"Warehouse Pick (mandatory)")
        then
            exit(StrSubstNo(MandatoryPickLbl, ProdOrderComponent."Item No.", ProdOrderComponent."Flushing Method", ProdOrderComponent."Location Code"));

        exit('');
    end;

    local procedure HasPickHandling(): Boolean
    begin
        exit(TempLocation."Require Pick" or
            (TempLocation."Prod. Consump. Whse. Handling" <> "Prod. Consump. Whse. Handling"::"No Warehouse Handling"));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        if TempLocation.Get(LocationCode) then
            exit;

        TempLocation.Init();
        TempLocation.Code := LocationCode;
        Location.SetLoadFields("Require Pick", "Prod. Consump. Whse. Handling");
        if (LocationCode <> '') and Location.Get(LocationCode) then begin
            TempLocation."Require Pick" := Location."Require Pick";
            TempLocation."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling";
        end;
        TempLocation.Insert();
    end;
}
