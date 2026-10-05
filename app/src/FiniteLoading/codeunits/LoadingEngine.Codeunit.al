namespace ManufacturingAdvanced.FiniteLoading;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;

codeunit 85702 "MFG Loading Engine"
{
    Access = Public;

    /// <summary>
    /// Builds the finite load plan of a work center: its open operations on firm planned and released orders,
    /// sequenced by the strategy in the setup and loaded day by day onto the capacity the capacity source gives,
    /// from the work date over the horizon. Changes no production order.
    /// </summary>
    /// <param name="WorkCenterNo">The work center.</param>
    /// <returns>The number of operations in the plan.</returns>
    procedure Calculate(WorkCenterNo: Code[20]): Integer
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGFiniteLoading);
        exit(CalculatePlan(WorkCenterNo));
    end;

    /// <summary>
    /// Builds the load plan without checking that the feature is enabled. Used by the sample data.
    /// </summary>
    /// <param name="WorkCenterNo">The work center.</param>
    /// <returns>The number of operations in the plan.</returns>
    procedure CalculatePlan(WorkCenterNo: Code[20]): Integer
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Setup: Record "MFG Loading Setup";
        Sequencer: Interface "MFG ISequencer";
    begin
        LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
        LoadPlanLine.DeleteAll();

        CollectOperations(WorkCenterNo);

        if not Setup.Get() then
            Clear(Setup);
        if Setup."Horizon Days" <= 0 then
            Setup."Horizon Days" := 30;
        Sequencer := Setup.Sequencing;
        LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
        Sequencer.Sequence(LoadPlanLine);

        Load(WorkCenterNo, Setup."Horizon Days");
        LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
        exit(LoadPlanLine.Count());
    end;

    local procedure CollectOperations(WorkCenterNo: Code[20])
    var
        WorkCenter: Record "Work Center";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProductionOrder: Record "Production Order";
        LoadPlanLine: Record "MFG Load Plan Line";
        ShopCalendarManagement: Codeunit "Shop Calendar Management";
        Factor: Decimal;
        Need: Decimal;
        EntryNo: Integer;
    begin
        WorkCenter.SetLoadFields("Unit of Measure Code");
        WorkCenter.Get(WorkCenterNo);
        Factor := 60000;
        if WorkCenter."Unit of Measure Code" <> '' then
            Factor := ShopCalendarManagement.TimeFactor(WorkCenter."Unit of Measure Code");
        if Factor = 0 then
            Factor := 60000;

        LoadPlanLine.Reset();
        if LoadPlanLine.FindLast() then
            EntryNo := LoadPlanLine."Entry No.";

        ProdOrderRoutingLine.SetRange("Work Center No.", WorkCenterNo);
        ProdOrderRoutingLine.SetFilter(Status, '%1|%2', ProdOrderRoutingLine.Status::"Firm Planned", ProdOrderRoutingLine.Status::Released);
        ProdOrderRoutingLine.SetFilter("Routing Status", '<>%1', ProdOrderRoutingLine."Routing Status"::Finished);
        if not ProdOrderRoutingLine.FindSet() then
            exit;

        repeat
            Need := Round(ProdOrderRoutingLine."Expected Capacity Need" / Factor, 0.01);
            if Need > 0 then begin
                EntryNo += 1;
                LoadPlanLine.Init();
                LoadPlanLine."Entry No." := EntryNo;
                LoadPlanLine."Work Center No." := WorkCenterNo;
                LoadPlanLine."Prod. Order Status" := ProdOrderRoutingLine.Status;
                LoadPlanLine."Prod. Order No." := ProdOrderRoutingLine."Prod. Order No.";
                LoadPlanLine."Routing Reference No." := ProdOrderRoutingLine."Routing Reference No.";
                LoadPlanLine."Routing No." := ProdOrderRoutingLine."Routing No.";
                LoadPlanLine."Operation No." := ProdOrderRoutingLine."Operation No.";
                LoadPlanLine.Description := ProdOrderRoutingLine.Description;
                LoadPlanLine.Need := Need;
                LoadPlanLine."Current Starting Date" := ProdOrderRoutingLine."Starting Date";
                LoadPlanLine."Current Ending Date" := ProdOrderRoutingLine."Ending Date";
                ProductionOrder.SetLoadFields("Due Date");
                if ProductionOrder.Get(ProdOrderRoutingLine.Status, ProdOrderRoutingLine."Prod. Order No.") then
                    LoadPlanLine."Due Date" := ProductionOrder."Due Date";
                LoadPlanLine.Insert(true);
            end;
        until ProdOrderRoutingLine.Next() = 0;
    end;

    local procedure Load(WorkCenterNo: Code[20]; HorizonDays: Integer)
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Locator: Codeunit "MFG Loading Locator";
        CapacitySource: Interface "MFG ICapacitySource";
        Day: Date;
        LastDay: Date;
        DayCapacity: Decimal;
        Remaining: Decimal;
        Take: Decimal;
    begin
        CapacitySource := Locator.CapacitySource();
        Day := WorkDate();
        LastDay := WorkDate() + HorizonDays - 1;
        DayCapacity := CapacitySource.DailyCapacity(WorkCenterNo, Day);

        LoadPlanLine.SetCurrentKey("Work Center No.", "Sequence No.");
        LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
        if not LoadPlanLine.FindSet(true) then
            exit;

        repeat
            Remaining := LoadPlanLine.Need;
            LoadPlanLine."Planned Starting Date" := 0D;
            LoadPlanLine."Planned Ending Date" := 0D;
            while (Remaining > 0) and (Day <= LastDay) do
                if DayCapacity <= 0 then begin
                    Day += 1;
                    if Day <= LastDay then
                        DayCapacity := CapacitySource.DailyCapacity(WorkCenterNo, Day);
                end else begin
                    if Remaining < DayCapacity then
                        Take := Remaining
                    else
                        Take := DayCapacity;
                    if LoadPlanLine."Planned Starting Date" = 0D then
                        LoadPlanLine."Planned Starting Date" := Day;
                    DayCapacity -= Take;
                    Remaining -= Take;
                    if Remaining = 0 then
                        LoadPlanLine."Planned Ending Date" := Day;
                end;

            LoadPlanLine."Fits Horizon" := Remaining = 0;
            LoadPlanLine.Late := not LoadPlanLine."Fits Horizon";
            LoadPlanLine."Days Late" := 0;
            if LoadPlanLine."Fits Horizon" and (LoadPlanLine."Due Date" <> 0D) and (LoadPlanLine."Planned Ending Date" > LoadPlanLine."Due Date") then begin
                LoadPlanLine.Late := true;
                LoadPlanLine."Days Late" := LoadPlanLine."Planned Ending Date" - LoadPlanLine."Due Date";
            end;
            LoadPlanLine.Modify(true);
        until LoadPlanLine.Next() = 0;
    end;
}
