namespace ManufacturingAdvanced.ShopFloor;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

codeunit 85602 "MFG Shop Floor Engine"
{
    Access = Public;

    var
        AlreadyRunningErr: Label 'You already have operation %1 of production order %2 running.', Comment = '%1 = the operation number, %2 = the production order number';
        NotRunningErr: Label 'This operation is not running.';
        NothingToReportErr: Label 'Enter an output quantity or a scrap quantity.';
        NegativeErr: Label 'Quantities and minutes cannot be negative.';
        NoMinutesErr: Label 'Enter the minutes the operation stood still.';
        NoOperationErr: Label 'Downtime can only be reported on an operation.';

    /// <summary>
    /// Starts the clock on an operation for the current user.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation, on a released production order.</param>
    /// <returns>The number of the session.</returns>
    procedure StartOperation(ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Integer
    var
        Session: Record "MFG Shop Floor Session";
    begin
        CheckEnabled();
        ProdOrderRoutingLine.TestField(Status, ProdOrderRoutingLine.Status::Released);
        if FindRunning(ProdOrderRoutingLine, Session) then
            Error(AlreadyRunningErr, ProdOrderRoutingLine."Operation No.", ProdOrderRoutingLine."Prod. Order No.");

        Session.Init();
        Session."Prod. Order No." := ProdOrderRoutingLine."Prod. Order No.";
        Session."Prod. Order Line No." := FindOrderLineNo(ProdOrderRoutingLine);
        Session."Routing Reference No." := ProdOrderRoutingLine."Routing Reference No.";
        Session."Routing No." := ProdOrderRoutingLine."Routing No.";
        Session."Operation No." := ProdOrderRoutingLine."Operation No.";
        Session."Work Center No." := ProdOrderRoutingLine."Work Center No.";
        Session."Item No." := FindItemNo(ProdOrderRoutingLine);
        Session.Operator := CopyStr(UserId(), 1, MaxStrLen(Session.Operator));
        Session."Started At" := CurrentDateTime();
        Session.Status := Session.Status::MFGRunning;
        Session.Insert(true);
        exit(Session."Entry No.");
    end;

    /// <summary>
    /// Stops the current user's clock on an operation and records the minutes it ran.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation.</param>
    /// <returns>The minutes the operation ran.</returns>
    procedure StopOperation(ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Decimal
    var
        Session: Record "MFG Shop Floor Session";
    begin
        CheckEnabled();
        if not FindRunning(ProdOrderRoutingLine, Session) then
            Error(NotRunningErr);

        Session."Stopped At" := CurrentDateTime();
        Session.Minutes := Round((Session."Stopped At" - Session."Started At") / 60000, 0.01);
        Session.Status := Session.Status::MFGStopped;
        Session.Modify(true);
        exit(Session.Minutes);
    end;

    /// <summary>
    /// Reports and posts output on an operation, with scrap, and with the run time clocked since the last output
    /// when the setup posts run time.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation.</param>
    /// <param name="OutputQuantity">The good quantity.</param>
    /// <param name="ScrapQuantity">The scrapped quantity.</param>
    /// <param name="ScrapCode">Why it was scrapped.</param>
    /// <returns>The number of the event.</returns>
    procedure ReportOperationOutput(ProdOrderRoutingLine: Record "Prod. Order Routing Line"; OutputQuantity: Decimal; ScrapQuantity: Decimal; ScrapCode: Code[10]): Integer
    var
        ShopFloorEvent: Record "MFG Shop Floor Event";
    begin
        CheckEnabled();
        CheckQuantities(OutputQuantity, ScrapQuantity);

        InitEvent(ShopFloorEvent, Enum::"MFG Shop Floor Event Type"::MFGOutput, ProdOrderRoutingLine."Prod. Order No.", FindOrderLineNo(ProdOrderRoutingLine), ProdOrderRoutingLine."Operation No.", FindItemNo(ProdOrderRoutingLine));
        ShopFloorEvent."Output Quantity" := OutputQuantity;
        ShopFloorEvent."Scrap Quantity" := ScrapQuantity;
        ShopFloorEvent."Scrap Code" := ScrapCode;
        ShopFloorEvent."Run Minutes" := TakeClockedMinutes(ProdOrderRoutingLine);
        exit(PostEvent(ShopFloorEvent));
    end;

    /// <summary>
    /// Reports and posts output on a production order line without a routing.
    /// </summary>
    /// <param name="ProdOrderLine">The released production order line.</param>
    /// <param name="OutputQuantity">The good quantity.</param>
    /// <param name="ScrapQuantity">The scrapped quantity.</param>
    /// <param name="ScrapCode">Why it was scrapped.</param>
    /// <returns>The number of the event.</returns>
    procedure ReportLineOutput(ProdOrderLine: Record "Prod. Order Line"; OutputQuantity: Decimal; ScrapQuantity: Decimal; ScrapCode: Code[10]): Integer
    var
        ShopFloorEvent: Record "MFG Shop Floor Event";
    begin
        CheckEnabled();
        CheckQuantities(OutputQuantity, ScrapQuantity);
        ProdOrderLine.TestField(Status, ProdOrderLine.Status::Released);

        InitEvent(ShopFloorEvent, Enum::"MFG Shop Floor Event Type"::MFGOutput, ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No.", '', ProdOrderLine."Item No.");
        ShopFloorEvent."Output Quantity" := OutputQuantity;
        ShopFloorEvent."Scrap Quantity" := ScrapQuantity;
        ShopFloorEvent."Scrap Code" := ScrapCode;
        exit(PostEvent(ShopFloorEvent));
    end;

    /// <summary>
    /// Reports and posts downtime on an operation.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation.</param>
    /// <param name="Minutes">How long it stood still.</param>
    /// <param name="StopCode">Why it stood still.</param>
    /// <returns>The number of the event.</returns>
    procedure ReportDowntime(ProdOrderRoutingLine: Record "Prod. Order Routing Line"; Minutes: Decimal; StopCode: Code[10]): Integer
    var
        ShopFloorEvent: Record "MFG Shop Floor Event";
    begin
        CheckEnabled();
        if ProdOrderRoutingLine."Operation No." = '' then
            Error(NoOperationErr);
        if Minutes < 0 then
            Error(NegativeErr);
        if Minutes = 0 then
            Error(NoMinutesErr);

        InitEvent(ShopFloorEvent, Enum::"MFG Shop Floor Event Type"::MFGDowntime, ProdOrderRoutingLine."Prod. Order No.", FindOrderLineNo(ProdOrderRoutingLine), ProdOrderRoutingLine."Operation No.", FindItemNo(ProdOrderRoutingLine));
        ShopFloorEvent."Stop Minutes" := Minutes;
        ShopFloorEvent."Stop Code" := StopCode;
        exit(PostEvent(ShopFloorEvent));
    end;

    /// <summary>
    /// Determines whether the current user has an operation running.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation.</param>
    /// <returns>True when it is running.</returns>
    procedure IsRunning(ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Boolean
    var
        Session: Record "MFG Shop Floor Session";
    begin
        exit(FindRunning(ProdOrderRoutingLine, Session));
    end;

    local procedure PostEvent(var ShopFloorEvent: Record "MFG Shop Floor Event"): Integer
    var
        Locator: Codeunit "MFG Shop Floor Locator";
    begin
        Locator.Posting().Post(ShopFloorEvent);
        ShopFloorEvent.Insert(true);
        exit(ShopFloorEvent."Entry No.");
    end;

    local procedure InitEvent(var ShopFloorEvent: Record "MFG Shop Floor Event"; EventType: Enum "MFG Shop Floor Event Type"; ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; OperationNo: Code[10]; ItemNo: Code[20])
    begin
        ShopFloorEvent.Init();
        ShopFloorEvent."Event Type" := EventType;
        ShopFloorEvent."Prod. Order No." := ProdOrderNo;
        ShopFloorEvent."Prod. Order Line No." := ProdOrderLineNo;
        ShopFloorEvent."Operation No." := OperationNo;
        ShopFloorEvent."Item No." := ItemNo;
        ShopFloorEvent."Reported At" := CurrentDateTime();
        ShopFloorEvent."Reported By" := CopyStr(UserId(), 1, MaxStrLen(ShopFloorEvent."Reported By"));
    end;

    local procedure TakeClockedMinutes(ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Decimal
    var
        Setup: Record "MFG Shop Floor Setup";
        Session: Record "MFG Shop Floor Session";
        Minutes: Decimal;
    begin
        Setup.SetLoadFields("Post Run Time");
        if not Setup.Get() then
            exit(0);
        if not Setup."Post Run Time" then
            exit(0);

        FilterSessions(ProdOrderRoutingLine, Session);
        Session.SetRange(Status, Session.Status::MFGStopped);
        Session.SetRange("Run Time Posted", false);
        if not Session.FindSet(true) then
            exit(0);

        repeat
            Minutes += Session.Minutes;
            Session."Run Time Posted" := true;
            Session.Modify(true);
        until Session.Next() = 0;
        exit(Minutes);
    end;

    local procedure FindRunning(ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var Session: Record "MFG Shop Floor Session"): Boolean
    begin
        FilterSessions(ProdOrderRoutingLine, Session);
        Session.SetRange(Status, Session.Status::MFGRunning);
        exit(Session.FindFirst());
    end;

    local procedure FilterSessions(ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var Session: Record "MFG Shop Floor Session")
    begin
        Session.SetCurrentKey("Prod. Order No.", "Routing Reference No.", "Routing No.", "Operation No.", Operator, Status);
        Session.SetRange("Prod. Order No.", ProdOrderRoutingLine."Prod. Order No.");
        Session.SetRange("Routing Reference No.", ProdOrderRoutingLine."Routing Reference No.");
        Session.SetRange("Routing No.", ProdOrderRoutingLine."Routing No.");
        Session.SetRange("Operation No.", ProdOrderRoutingLine."Operation No.");
        Session.SetRange(Operator, CopyStr(UserId(), 1, MaxStrLen(Session.Operator)));
    end;

    local procedure FindOrderLineNo(ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Integer
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetLoadFields("Line No.");
        ProdOrderLine.SetRange(Status, ProdOrderRoutingLine.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrderRoutingLine."Prod. Order No.");
        ProdOrderLine.SetRange("Routing Reference No.", ProdOrderRoutingLine."Routing Reference No.");
        ProdOrderLine.SetRange("Routing No.", ProdOrderRoutingLine."Routing No.");
        if ProdOrderLine.FindFirst() then
            exit(ProdOrderLine."Line No.");
        exit(ProdOrderRoutingLine."Routing Reference No.");
    end;

    local procedure FindItemNo(ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Code[20]
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetLoadFields("Item No.");
        if ProdOrderLine.Get(ProdOrderRoutingLine.Status, ProdOrderRoutingLine."Prod. Order No.", FindOrderLineNo(ProdOrderRoutingLine)) then
            exit(ProdOrderLine."Item No.");
        exit('');
    end;

    local procedure CheckQuantities(OutputQuantity: Decimal; ScrapQuantity: Decimal)
    begin
        if (OutputQuantity < 0) or (ScrapQuantity < 0) then
            Error(NegativeErr);
        if (OutputQuantity = 0) and (ScrapQuantity = 0) then
            Error(NothingToReportErr);
    end;

    local procedure CheckEnabled()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGShopFloor);
    end;
}
