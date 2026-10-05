namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;
using Microsoft.Warehouse.Activity;

codeunit 85211 "MFG Check Open Whse. Activity" implements "MFG IFinishCheck"
{
    Access = Public;

    var
        DescriptionLbl: Label 'A warehouse or inventory pick for the order''s components is still open, so goods may be on their way to production that the finished order will never consume.';
        ReasonLbl: Label 'Warehouse activity %1 still has %2 open line(s) for this order. Register or delete it first.', Comment = '%1 = the warehouse activity number, %2 = the number of lines';

    /// <summary>
    /// Reports an order with open warehouse activity lines for its components.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    /// <param name="Reason">Set when an activity is open.</param>
    /// <returns>True when an activity is open.</returns>
    procedure Evaluate(ProductionOrder: Record "Production Order"; var Reason: Text): Boolean
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        WarehouseActivityLine.SetLoadFields("No.");
        WarehouseActivityLine.SetRange("Source Type", Database::"Prod. Order Component");
        WarehouseActivityLine.SetRange("Source Subtype", ProductionOrder.Status.AsInteger());
        WarehouseActivityLine.SetRange("Source No.", ProductionOrder."No.");
        if not WarehouseActivityLine.FindFirst() then
            exit(false);

        Reason := StrSubstNo(ReasonLbl, WarehouseActivityLine."No.", WarehouseActivityLine.Count());
        exit(true);
    end;

    /// <summary>
    /// An open pick leaves goods in limbo, so it blocks by default.
    /// </summary>
    /// <returns>Block.</returns>
    procedure DefaultSeverity(): Enum "MFG Finish Check Severity"
    begin
        exit(Enum::"MFG Finish Check Severity"::MFGBlock);
    end;

    /// <summary>
    /// Describes the check.
    /// </summary>
    /// <returns>The description.</returns>
    procedure Description(): Text
    begin
        exit(DescriptionLbl);
    end;
}
