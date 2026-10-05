namespace ManufacturingAdvanced.FiniteLoading;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;

codeunit 85702 "MFG Loading Engine"
{
    Access = Public;

    var
        PreviousSeparatorTok: Label '|', Locked = true;
        CapacityKeyTok: Label '%1|%2', Locked = true;
        WriteBackNotAllowedErr: Label 'Applying the load plan to production orders is not allowed. Turn on Allow applying the plan to orders on the finite loading setup.';

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

    /// <summary>
    /// Builds the finite load plan of every work center with open operations at once, so that an operation cannot
    /// start before the operations of its routing that come before it have ended, wherever they are loaded. Each
    /// work center is sequenced with the strategy in the setup; the work centers then take turns loading their next
    /// operation whose previous operations are planned. Changes no production order.
    /// </summary>
    /// <returns>The number of operations in the plan.</returns>
    procedure CalculateAll(): Integer
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGFiniteLoading);
        exit(CalculateAllPlan());
    end;

    /// <summary>
    /// Builds the load plan of every work center without checking that the feature is enabled.
    /// </summary>
    /// <returns>The number of operations in the plan.</returns>
    procedure CalculateAllPlan(): Integer
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        WorkCenter: Record "Work Center";
        Setup: Record "MFG Loading Setup";
        Sequencer: Interface "MFG ISequencer";
        WorkCenters: List of [Code[20]];
    begin
        LoadPlanLine.DeleteAll();
        if not Setup.Get() then
            Clear(Setup);
        if Setup."Horizon Days" <= 0 then
            Setup."Horizon Days" := 30;
        Sequencer := Setup.Sequencing;

        WorkCenter.SetLoadFields("No.");
        if WorkCenter.FindSet() then
            repeat
                CollectOperations(WorkCenter."No.");
                LoadPlanLine.SetRange("Work Center No.", WorkCenter."No.");
                if not LoadPlanLine.IsEmpty() then begin
                    WorkCenters.Add(WorkCenter."No.");
                    Sequencer.Sequence(LoadPlanLine);
                end;
            until WorkCenter.Next() = 0;

        LoadAll(WorkCenters, Setup."Horizon Days");
        LoadPlanLine.Reset();
        exit(LoadPlanLine.Count());
    end;

    /// <summary>
    /// Applies the load plan of a work center to the production orders: every operation that fits the horizon and
    /// whose planned starting date differs from its current one is moved there through the write-back, in plan
    /// sequence. Requires the feature to be enabled and write-back to be allowed in the setup.
    /// </summary>
    /// <param name="WorkCenterNo">The work center whose calculated plan is applied; empty for every work center, in the
    /// order of the planned starting dates.</param>
    /// <returns>The number of operations moved.</returns>
    procedure ApplyPlan(WorkCenterNo: Code[20]): Integer
    var
        Setup: Record "MFG Loading Setup";
        LoadPlanLine: Record "MFG Load Plan Line";
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Locator: Codeunit "MFG Loading Locator";
        WriteBack: Interface "MFG IPlanWriteBack";
        Applied: Integer;
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGFiniteLoading);
        if not Setup.Get() then
            Clear(Setup);
        if not Setup."Allow Write-Back" then
            Error(WriteBackNotAllowedErr);

        WriteBack := Locator.WriteBack();
        if WorkCenterNo = '' then
            LoadPlanLine.SetCurrentKey("Planned Starting Date", "Work Center No.", "Sequence No.")
        else begin
            LoadPlanLine.SetCurrentKey("Work Center No.", "Sequence No.");
            LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
        end;
        LoadPlanLine.SetRange("Fits Horizon", true);
        LoadPlanLine.SetRange("Written Back", false);
        if not LoadPlanLine.FindSet(true) then
            exit(0);

        repeat
            if (LoadPlanLine."Planned Starting Date" <> 0D) and (LoadPlanLine."Planned Starting Date" <> LoadPlanLine."Current Starting Date") then
                if WriteBack.Apply(LoadPlanLine) then begin
                    LoadPlanLine."Written Back" := true;
                    LoadPlanLine."Current Starting Date" := LoadPlanLine."Planned Starting Date";
                    LoadPlanLine.Modify(true);
                    Applied += 1;
                end;
        until LoadPlanLine.Next() = 0;
        exit(Applied);
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
                LoadPlanLine."Previous Operation No." := ProdOrderRoutingLine."Previous Operation No.";
                LoadPlanLine."Capacity Type" := ProdOrderRoutingLine.Type;
                LoadPlanLine."Capacity No." := ProdOrderRoutingLine."No.";
                if LoadPlanLine."Capacity No." = '' then begin
                    LoadPlanLine."Capacity Type" := LoadPlanLine."Capacity Type"::"Work Center";
                    LoadPlanLine."Capacity No." := WorkCenterNo;
                end;
                ProductionOrder.SetLoadFields("Due Date");
                if ProductionOrder.Get(ProdOrderRoutingLine.Status, ProdOrderRoutingLine."Prod. Order No.") then
                    LoadPlanLine."Due Date" := ProductionOrder."Due Date";
                LoadPlanLine.Insert(true);
            end;
        until ProdOrderRoutingLine.Next() = 0;
    end;

    /// <summary>
    /// Loads one work center in its sequence. Each operation goes onto the calendar of the capacity it runs on: the
    /// work center itself, or one of its machine centers, each with its own place in the day.
    /// </summary>
    local procedure Load(WorkCenterNo: Code[20]; HorizonDays: Integer)
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Locator: Codeunit "MFG Loading Locator";
        CapacitySource: Interface "MFG ICapacitySource";
        Days: Dictionary of [Text, Date];
        Capacities: Dictionary of [Text, Decimal];
        CapacityKey: Text;
        LastDay: Date;
        Day: Date;
        DayCapacity: Decimal;
    begin
        CapacitySource := Locator.CapacitySource();
        LastDay := WorkDate() + HorizonDays - 1;

        LoadPlanLine.SetCurrentKey("Work Center No.", "Sequence No.");
        LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
        if not LoadPlanLine.FindSet(true) then
            exit;

        repeat
            CapacityKey := KeyOf(LoadPlanLine);
            if not Days.ContainsKey(CapacityKey) then begin
                Days.Add(CapacityKey, WorkDate());
                Capacities.Add(CapacityKey, CapacitySource.DailyCapacity(LoadPlanLine."Capacity Type", LoadPlanLine."Capacity No.", WorkDate()));
            end;
            Day := Days.Get(CapacityKey);
            DayCapacity := Capacities.Get(CapacityKey);
            LoadOne(LoadPlanLine, CapacitySource, Day, DayCapacity, LastDay);
            Days.Set(CapacityKey, Day);
            Capacities.Set(CapacityKey, DayCapacity);
        until LoadPlanLine.Next() = 0;
    end;

    /// <summary>
    /// Loads every work center together. Each work center's sequence is split into one queue per capacity (the work
    /// center and each of its machine centers); the queues take turns loading their next operation once its previous
    /// operations are planned.
    /// </summary>
    local procedure LoadAll(WorkCenters: List of [Code[20]]; HorizonDays: Integer)
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Locator: Codeunit "MFG Loading Locator";
        CapacitySource: Interface "MFG ICapacitySource";
        Queues: Dictionary of [Text, List of [Integer]];
        Days: Dictionary of [Text, Date];
        Capacities: Dictionary of [Text, Decimal];
        Loaded: Dictionary of [Integer, Boolean];
        CapacityKeys: List of [Text];
        Queue: List of [Integer];
        WorkCenterNo: Code[20];
        CapacityKey: Text;
        LastDay: Date;
        Day: Date;
        DayCapacity: Decimal;
        Earliest: Date;
        Progress: Boolean;
        Blocked: Boolean;
        Fits: Boolean;
    begin
        CapacitySource := Locator.CapacitySource();
        LastDay := WorkDate() + HorizonDays - 1;
        foreach WorkCenterNo in WorkCenters do begin
            LoadPlanLine.SetCurrentKey("Work Center No.", "Sequence No.");
            LoadPlanLine.SetRange("Work Center No.", WorkCenterNo);
            if LoadPlanLine.FindSet() then
                repeat
                    CapacityKey := KeyOf(LoadPlanLine);
                    if not Queues.ContainsKey(CapacityKey) then begin
                        Clear(Queue);
                        Queues.Add(CapacityKey, Queue);
                        CapacityKeys.Add(CapacityKey);
                        Days.Add(CapacityKey, WorkDate());
                        Capacities.Add(CapacityKey, CapacitySource.DailyCapacity(LoadPlanLine."Capacity Type", LoadPlanLine."Capacity No.", WorkDate()));
                    end;
                    Queue := Queues.Get(CapacityKey);
                    Queue.Add(LoadPlanLine."Entry No.");
                    Queues.Set(CapacityKey, Queue);
                until LoadPlanLine.Next() = 0;
        end;

        repeat
            Progress := false;
            foreach CapacityKey in CapacityKeys do begin
                Queue := Queues.Get(CapacityKey);
                if Queue.Count() > 0 then begin
                    LoadPlanLine.Get(Queue.Get(1));
                    PreviousState(LoadPlanLine, Loaded, Blocked, Fits, Earliest);
                    if not Blocked then begin
                        Queue.RemoveAt(1);
                        Queues.Set(CapacityKey, Queue);
                        Progress := true;
                        LoadPlanLine."Earliest Start Date" := Earliest;
                        if not Fits then
                            MarkNotFitting(LoadPlanLine)
                        else begin
                            Day := Days.Get(CapacityKey);
                            DayCapacity := Capacities.Get(CapacityKey);
                            if Day < Earliest then begin
                                Day := Earliest;
                                DayCapacity := CapacitySource.DailyCapacity(LoadPlanLine."Capacity Type", LoadPlanLine."Capacity No.", Day);
                            end;
                            LoadOne(LoadPlanLine, CapacitySource, Day, DayCapacity, LastDay);
                            Days.Set(CapacityKey, Day);
                            Capacities.Set(CapacityKey, DayCapacity);
                        end;
                        Loaded.Set(LoadPlanLine."Entry No.", LoadPlanLine."Fits Horizon");
                    end;
                end;
            end;
        until not Progress;

        // whatever is left waits for an operation that can never be planned
        foreach CapacityKey in CapacityKeys do begin
            Queue := Queues.Get(CapacityKey);
            while Queue.Count() > 0 do begin
                LoadPlanLine.Get(Queue.Get(1));
                Queue.RemoveAt(1);
                Queues.Set(CapacityKey, Queue);
                MarkNotFitting(LoadPlanLine);
            end;
        end;
    end;

    local procedure KeyOf(LoadPlanLine: Record "MFG Load Plan Line"): Text
    begin
        exit(StrSubstNo(CapacityKeyTok, LoadPlanLine."Capacity Type".AsInteger(), LoadPlanLine."Capacity No."));
    end;

    local procedure PreviousState(LoadPlanLine: Record "MFG Load Plan Line"; Loaded: Dictionary of [Integer, Boolean]; var Blocked: Boolean; var Fits: Boolean; var Earliest: Date)
    var
        Previous: Record "MFG Load Plan Line";
        PreviousOperations: Text;
        OperationNo: Text;
        PreviousFits: Boolean;
    begin
        Blocked := false;
        Fits := true;
        Earliest := 0D;
        if LoadPlanLine."Previous Operation No." = '' then
            exit;

        PreviousOperations := LoadPlanLine."Previous Operation No.";
        foreach OperationNo in PreviousOperations.Split(PreviousSeparatorTok) do begin
            Previous.SetCurrentKey("Prod. Order Status", "Prod. Order No.", "Routing Reference No.", "Routing No.", "Operation No.");
            Previous.SetRange("Prod. Order Status", LoadPlanLine."Prod. Order Status");
            Previous.SetRange("Prod. Order No.", LoadPlanLine."Prod. Order No.");
            Previous.SetRange("Routing Reference No.", LoadPlanLine."Routing Reference No.");
            Previous.SetRange("Routing No.", LoadPlanLine."Routing No.");
            Previous.SetRange("Operation No.", CopyStr(OperationNo.Trim(), 1, MaxStrLen(Previous."Operation No.")));
            if Previous.FindFirst() then
                if not Loaded.Get(Previous."Entry No.", PreviousFits) then
                    Blocked := true
                else
                    if not PreviousFits then
                        Fits := false
                    else
                        if Previous."Planned Ending Date" > Earliest then
                            Earliest := Previous."Planned Ending Date";
        end;
    end;

    local procedure MarkNotFitting(var LoadPlanLine: Record "MFG Load Plan Line")
    begin
        LoadPlanLine."Planned Starting Date" := 0D;
        LoadPlanLine."Planned Ending Date" := 0D;
        LoadPlanLine."Fits Horizon" := false;
        LoadPlanLine.Late := true;
        LoadPlanLine."Days Late" := 0;
        LoadPlanLine.Modify(true);
    end;

    local procedure LoadOne(var LoadPlanLine: Record "MFG Load Plan Line"; CapacitySource: Interface "MFG ICapacitySource"; var Day: Date; var DayCapacity: Decimal; LastDay: Date)
    var
        Remaining: Decimal;
        Take: Decimal;
    begin
        Remaining := LoadPlanLine.Need;
        LoadPlanLine."Planned Starting Date" := 0D;
        LoadPlanLine."Planned Ending Date" := 0D;
        while (Remaining > 0) and (Day <= LastDay) do
            if DayCapacity <= 0 then begin
                Day += 1;
                if Day <= LastDay then
                    DayCapacity := CapacitySource.DailyCapacity(LoadPlanLine."Capacity Type", LoadPlanLine."Capacity No.", Day);
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
    end;
}
