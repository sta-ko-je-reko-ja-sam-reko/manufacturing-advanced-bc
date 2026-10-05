namespace ManufacturingAdvanced.Preflight;

using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;

codeunit 85112 "MFG Check Missing Bin" implements "MFG IPreflightCheck"
{
    Access = Public;

    var
        TempBinMandatory: Record Location temporary;
        DescriptionLbl: Label 'A component or an output line is at a location that requires bins, but has no bin code, so consumption or output cannot post. Usually the location, work centre or machine centre has no production bin set up.';
        OutputFindingLbl: Label 'Line %1 outputs item %2 at location %3, which requires bins, but has no bin code. Set the From-Production Bin Code on the location, work centre or machine centre, or enter a bin on the line.', Comment = '%1 = the production order line number, %2 = the item number, %3 = the location code';
        ComponentFindingLbl: Label 'Component %1 is consumed at location %2, which requires bins, but has no bin code. Set the To-Production or Open Shop Floor Bin Code on the location, work centre or machine centre, or enter a bin on the component.', Comment = '%1 = the component item number, %2 = the location code';

    /// <summary>
    /// Reports every output line and component at a bin-mandatory location that has no bin code.
    /// </summary>
    /// <param name="ProductionOrder">The order to inspect.</param>
    /// <param name="Collector">Receives the findings.</param>
    procedure Run(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    begin
        CheckOutput(ProductionOrder, Collector);
        CheckComponents(ProductionOrder, Collector);
    end;

    /// <summary>
    /// A missing bin makes posting fail, so it is an error by default.
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

    local procedure CheckOutput(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetLoadFields("Item No.", "Location Code", "Bin Code");
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.SetRange("Bin Code", '');
        if not ProdOrderLine.FindSet() then
            exit;

        repeat
            if IsBinMandatory(ProdOrderLine."Location Code") then
                Collector.Add(
                    ProdOrderLine."Line No.", 0, ProdOrderLine."Item No.", ProdOrderLine."Location Code",
                    StrSubstNo(OutputFindingLbl, ProdOrderLine."Line No.", ProdOrderLine."Item No.", ProdOrderLine."Location Code"));
        until ProdOrderLine.Next() = 0;
    end;

    local procedure CheckComponents(ProductionOrder: Record "Production Order"; var Collector: Codeunit "MFG Preflight Collector")
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.SetLoadFields("Item No.", "Location Code", "Bin Code");
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetRange("Bin Code", '');
        if not ProdOrderComponent.FindSet() then
            exit;

        repeat
            if IsBinMandatory(ProdOrderComponent."Location Code") then
                Collector.Add(
                    ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Line No.", ProdOrderComponent."Item No.", ProdOrderComponent."Location Code",
                    StrSubstNo(ComponentFindingLbl, ProdOrderComponent."Item No.", ProdOrderComponent."Location Code"));
        until ProdOrderComponent.Next() = 0;
    end;

    local procedure IsBinMandatory(LocationCode: Code[10]): Boolean
    var
        Location: Record Location;
    begin
        if LocationCode = '' then
            exit(false);

        if not TempBinMandatory.Get(LocationCode) then begin
            Location.SetLoadFields("Bin Mandatory");
            TempBinMandatory.Init();
            TempBinMandatory.Code := LocationCode;
            if Location.Get(LocationCode) then
                TempBinMandatory."Bin Mandatory" := Location."Bin Mandatory";
            TempBinMandatory.Insert();
        end;

        exit(TempBinMandatory."Bin Mandatory");
    end;
}
