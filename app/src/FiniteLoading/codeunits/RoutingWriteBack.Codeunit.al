namespace ManufacturingAdvanced.FiniteLoading;

using Microsoft.Manufacturing.Document;

codeunit 85709 "MFG Routing Write-Back" implements "MFG IPlanWriteBack"
{
    Access = Public;

    /// <summary>
    /// Validates the operation's starting date-time to the planned starting date at its current starting time, as
    /// a planner would on the production order routing. Business Central then reschedules the operation, the
    /// operations after it and the order line, and checks for date conflicts with reservations.
    /// </summary>
    /// <param name="LoadPlanLine">The load plan line.</param>
    /// <returns>True when the operation was moved; false when it no longer exists or is finished.</returns>
    procedure Apply(LoadPlanLine: Record "MFG Load Plan Line"): Boolean
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        StartingTime: Time;
    begin
        if not ProdOrderRoutingLine.Get(
            LoadPlanLine."Prod. Order Status", LoadPlanLine."Prod. Order No.", LoadPlanLine."Routing Reference No.",
            LoadPlanLine."Routing No.", LoadPlanLine."Operation No.")
        then
            exit(false);
        if ProdOrderRoutingLine."Routing Status" = ProdOrderRoutingLine."Routing Status"::Finished then
            exit(false);

        StartingTime := ProdOrderRoutingLine."Starting Time";
        if StartingTime = 0T then
            StartingTime := 000000T;
        ProdOrderRoutingLine.Validate("Starting Date-Time", CreateDateTime(LoadPlanLine."Planned Starting Date", StartingTime));
        exit(true);
    end;
}
