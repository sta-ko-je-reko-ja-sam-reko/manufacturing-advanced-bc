namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

codeunit 85210 "MFG Check Missing Consumption" implements "MFG IFinishCheck"
{
    Access = Public;

    var
        DescriptionLbl: Label 'A component still has a remaining quantity, so finishing now would leave its cost out of the order and the variance would be wrong.';
        ReasonLbl: Label '%1 component line(s) still have quantity to consume, starting with item %2.', Comment = '%1 = the number of component lines, %2 = the first component item number';

    /// <summary>
    /// Reports an order with any component whose remaining quantity is more than zero.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    /// <param name="Reason">Set when consumption is missing.</param>
    /// <returns>True when consumption is missing.</returns>
    procedure Evaluate(ProductionOrder: Record "Production Order"; var Reason: Text): Boolean
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.SetLoadFields("Item No.");
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetFilter("Remaining Quantity", '>0');
        if not ProdOrderComponent.FindFirst() then
            exit(false);

        Reason := StrSubstNo(ReasonLbl, ProdOrderComponent.Count(), ProdOrderComponent."Item No.");
        exit(true);
    end;

    /// <summary>
    /// Finishing with consumption missing distorts the cost, so it blocks by default.
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
