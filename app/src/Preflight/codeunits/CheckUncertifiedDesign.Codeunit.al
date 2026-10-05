namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;

codeunit 85113 "MFG Check Uncertified Design" implements "MFG IPreflightCheck"
{
    Access = Public;

    var
        DescriptionLbl: Label 'The production BOM or routing a line was calculated from is no longer certified, for example because it was set to Under Development or Closed after the order was refreshed.';
        BomFindingLbl: Label 'Line %1 was calculated from production BOM %2 %3, which is %4, not Certified. Check the design before releasing.', Comment = '%1 = the production order line number, %2 = the production BOM number, %3 = the version code, %4 = the status';
        RoutingFindingLbl: Label 'Line %1 was calculated from routing %2 %3, which is %4, not Certified. Check the design before releasing.', Comment = '%1 = the production order line number, %2 = the routing number, %3 = the version code, %4 = the status';
        MissingLbl: Label 'missing';

    /// <summary>
    /// Reports every order line whose production BOM or routing, or the version of either it uses, is
    /// not certified or no longer exists.
    /// </summary>
    /// <param name="ProductionOrder">The order to inspect.</param>
    /// <param name="Collector">Receives the findings.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderLine: Record "Prod. Order Line";
        StatusText: Text;
    begin
        ProdOrderLine.SetLoadFields("Item No.", "Location Code", "Production BOM No.", "Production BOM Version Code", "Routing No.", "Routing Version Code");
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if not ProdOrderLine.FindSet() then
            exit;

        repeat
            if (ProdOrderLine."Production BOM No." <> '') and not IsBomCertified(ProdOrderLine, StatusText) then
                Collector.Add(
                    ProdOrderLine."Line No.", 0, ProdOrderLine."Item No.", ProdOrderLine."Location Code",
                    StrSubstNo(BomFindingLbl, ProdOrderLine."Line No.", ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code", StatusText));
            if (ProdOrderLine."Routing No." <> '') and not IsRoutingCertified(ProdOrderLine, StatusText) then
                Collector.Add(
                    ProdOrderLine."Line No.", 0, ProdOrderLine."Item No.", ProdOrderLine."Location Code",
                    StrSubstNo(RoutingFindingLbl, ProdOrderLine."Line No.", ProdOrderLine."Routing No.", ProdOrderLine."Routing Version Code", StatusText));
        until ProdOrderLine.Next() = 0;
    end;

    /// <summary>
    /// An uncertified design does not stop posting, so it is a warning by default.
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

    local procedure IsBomCertified(ProdOrderLine: Record "Prod. Order Line"; var StatusText: Text): Boolean
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        StatusText := MissingLbl;
        if ProdOrderLine."Production BOM Version Code" <> '' then begin
            ProductionBOMVersion.SetLoadFields(Status);
            if not ProductionBOMVersion.Get(ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code") then
                exit(false);
            StatusText := Format(ProductionBOMVersion.Status);
            exit(ProductionBOMVersion.Status = ProductionBOMVersion.Status::Certified);
        end;

        ProductionBOMHeader.SetLoadFields(Status);
        if not ProductionBOMHeader.Get(ProdOrderLine."Production BOM No.") then
            exit(false);
        StatusText := Format(ProductionBOMHeader.Status);
        exit(ProductionBOMHeader.Status = ProductionBOMHeader.Status::Certified);
    end;

    local procedure IsRoutingCertified(ProdOrderLine: Record "Prod. Order Line"; var StatusText: Text): Boolean
    var
        RoutingHeader: Record "Routing Header";
        RoutingVersion: Record "Routing Version";
    begin
        StatusText := MissingLbl;
        if ProdOrderLine."Routing Version Code" <> '' then begin
            RoutingVersion.SetLoadFields(Status);
            if not RoutingVersion.Get(ProdOrderLine."Routing No.", ProdOrderLine."Routing Version Code") then
                exit(false);
            StatusText := Format(RoutingVersion.Status);
            exit(RoutingVersion.Status = RoutingVersion.Status::Certified);
        end;

        RoutingHeader.SetLoadFields(Status);
        if not RoutingHeader.Get(ProdOrderLine."Routing No.") then
            exit(false);
        StatusText := Format(RoutingHeader.Status);
        exit(RoutingHeader.Status = RoutingHeader.Status::Certified);
    end;
}
