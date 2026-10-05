namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

codeunit 85212 "MFG Check Unfinished Ops." implements "MFG IFinishCheck"
{
    Access = Public;

    var
        DescriptionLbl: Label 'An operation on the order''s routing is not marked finished, which usually means its capacity, such as run time or setup time, has not been posted yet.';
        ReasonLbl: Label '%1 operation(s) are not finished, starting with operation %2. Post their capacity if it is missing.', Comment = '%1 = the number of operations, %2 = the first operation number';

    /// <summary>
    /// Reports an order with routing lines whose routing status is not Finished.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    /// <param name="Reason">Set when an operation is not finished.</param>
    /// <returns>True when an operation is not finished.</returns>
    procedure Evaluate(ProductionOrder: Record "Production Order"; var Reason: Text): Boolean
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.SetLoadFields("Operation No.");
        ProdOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderRoutingLine.SetFilter("Routing Status", '<>%1', ProdOrderRoutingLine."Routing Status"::Finished);
        if not ProdOrderRoutingLine.FindFirst() then
            exit(false);

        Reason := StrSubstNo(ReasonLbl, ProdOrderRoutingLine.Count(), ProdOrderRoutingLine."Operation No.");
        exit(true);
    end;

    /// <summary>
    /// Many orders post capacity without marking the operation finished, so it only informs by default.
    /// </summary>
    /// <returns>Inform.</returns>
    procedure DefaultSeverity(): Enum "MFG Finish Check Severity"
    begin
        exit(Enum::"MFG Finish Check Severity"::MFGInform);
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
