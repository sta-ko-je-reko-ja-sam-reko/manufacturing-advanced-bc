namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

codeunit 85110 "MFG Check Routing Link" implements "MFG IPreflightCheck"
{
    Access = Public;

    var
        DescriptionLbl: Label 'A component carries a routing link code that no operation on its production order line has, so it is never consumed at an operation and backward flushing never picks it up.';
        FindingLbl: Label 'Component %1 has routing link %2, but no operation on line %3 has that link. Add the link to an operation or clear it on the component.', Comment = '%1 = the component item number, %2 = the routing link code, %3 = the production order line number';

    /// <summary>
    /// Reports every component whose routing link code matches no routing line of its order line.
    /// </summary>
    /// <param name="ProductionOrder">The order to inspect.</param>
    /// <param name="Collector">Receives the findings.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetLoadFields("Routing No.", "Routing Reference No.");
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if not ProdOrderLine.FindSet() then
            exit;

        repeat
            CheckComponents(ProdOrderLine, Collector);
        until ProdOrderLine.Next() = 0;
    end;

    /// <summary>
    /// A link that leads nowhere does not stop posting, so it is a warning by default.
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

    local procedure CheckComponents(ProdOrderLine: Record "Prod. Order Line"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.SetLoadFields("Item No.", "Location Code", "Routing Link Code");
        ProdOrderComponent.SetRange(Status, ProdOrderLine.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
        ProdOrderComponent.SetFilter("Routing Link Code", '<>%1', '');
        if not ProdOrderComponent.FindSet() then
            exit;

        repeat
            if not OperationHasLink(ProdOrderLine, ProdOrderComponent."Routing Link Code") then
                Collector.Add(
                    ProdOrderLine."Line No.", ProdOrderComponent."Line No.", ProdOrderComponent."Item No.", ProdOrderComponent."Location Code",
                    StrSubstNo(FindingLbl, ProdOrderComponent."Item No.", ProdOrderComponent."Routing Link Code", ProdOrderLine."Line No."));
        until ProdOrderComponent.Next() = 0;
    end;

    local procedure OperationHasLink(ProdOrderLine: Record "Prod. Order Line"; RoutingLinkCode: Code[10]): Boolean
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.SetRange(Status, ProdOrderLine.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdOrderRoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
        ProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
        ProdOrderRoutingLine.SetRange("Routing Link Code", RoutingLinkCode);
        exit(not ProdOrderRoutingLine.IsEmpty());
    end;
}
