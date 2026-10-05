namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.FiniteLoading;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89018 "MFG Loading Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestCapacitySource: Codeunit "MFG Test Capacity Source";
        TestPlanWriteBack: Codeunit "MFG Test Plan Write-Back";

    [Test]
    procedure TheOrderDueFirstIsLoadedFirst()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] 480 minutes a day; order A due in five days needs 600 minutes, order B due tomorrow needs 300
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        CreateOperation('MFGL-A', WorkDate() + 5, 600);
        CreateOperation('MFGL-B', WorkDate() + 1, 300);

        // [WHEN] The load plan is calculated
        Assert.AreEqual(2, Engine.Calculate(WorkCenterNo()), 'Both operations are loaded.');

        // [THEN] B goes first and finishes today; A starts today with the 180 minutes left and finishes tomorrow
        FindLine(LoadPlanLine, 'MFGL-B');
        Assert.AreEqual(1, LoadPlanLine."Sequence No.", 'The order due first is loaded first.');
        Assert.AreEqual(WorkDate(), LoadPlanLine."Planned Ending Date", 'B fits today.');
        FindLine(LoadPlanLine, 'MFGL-A');
        Assert.AreEqual(WorkDate(), LoadPlanLine."Planned Starting Date", 'A starts in what is left of today.');
        Assert.AreEqual(WorkDate() + 1, LoadPlanLine."Planned Ending Date", 'A finishes tomorrow.');
        Assert.IsFalse(LoadPlanLine.Late, 'A finishes before it is due.');
    end;

    [Test]
    procedure AnOperationFinishingAfterItsDueDateIsLate()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] 480 minutes a day, and an order due today that needs 600 minutes
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        CreateOperation('MFGL-C', WorkDate(), 600);

        // [WHEN] The load plan is calculated
        Engine.Calculate(WorkCenterNo());

        // [THEN] It finishes tomorrow, one day late
        FindLine(LoadPlanLine, 'MFGL-C');
        Assert.IsTrue(LoadPlanLine.Late, 'The operation is late.');
        Assert.AreEqual(1, LoadPlanLine."Days Late", 'One day late.');
    end;

    [Test]
    procedure ShortestFirstLoadsTheSmallestOperationFirst()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] Shortest first; order D due today needs 600 minutes, order E due later needs 100
        Prepare(Enum::"MFG Sequencing Strategy"::MFGShortestFirst, 30);
        CreateOperation('MFGL-D', WorkDate(), 600);
        CreateOperation('MFGL-E', WorkDate() + 3, 100);

        // [WHEN] The load plan is calculated
        Engine.Calculate(WorkCenterNo());

        // [THEN] E goes first despite its later due date
        FindLine(LoadPlanLine, 'MFGL-E');
        Assert.AreEqual(1, LoadPlanLine."Sequence No.", 'The shortest operation is loaded first.');
    end;

    [Test]
    procedure OrderNumberLoadsFirstInFirstOut()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] Sequencing by order number; order G due today, order F due later
        Prepare(Enum::"MFG Sequencing Strategy"::MFGOrderNo, 30);
        CreateOperation('MFGL-G', WorkDate(), 100);
        CreateOperation('MFGL-F', WorkDate() + 3, 100);

        // [WHEN] The load plan is calculated
        Engine.Calculate(WorkCenterNo());

        // [THEN] F, the lower order number, goes first
        FindLine(LoadPlanLine, 'MFGL-F');
        Assert.AreEqual(1, LoadPlanLine."Sequence No.", 'The lower order number is loaded first.');
    end;

    [Test]
    procedure WorkBeyondTheHorizonDoesNotFit()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] A one-day horizon of 480 minutes, and an operation that needs 600
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 1);
        CreateOperation('MFGL-H', WorkDate() + 10, 600);

        // [WHEN] The load plan is calculated
        Engine.Calculate(WorkCenterNo());

        // [THEN] It does not fit, and counts as late
        FindLine(LoadPlanLine, 'MFGL-H');
        Assert.IsFalse(LoadPlanLine."Fits Horizon", 'The operation does not fit the horizon.');
        Assert.IsTrue(LoadPlanLine.Late, 'Work that does not fit is late.');
    end;

    [Test]
    procedure TheCalendarSourceSumsTheDaysEntries()
    var
        CalendarCapacity: Codeunit "MFG Calendar Capacity";
    begin
        // [GIVEN] Two calendar entries of 240 minutes for the work center today
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        AddCalendarEntry(080000T, 120000T, 240);
        AddCalendarEntry(130000T, 170000T, 240);

        // [WHEN] / [THEN] The day's capacity is 480
        Assert.AreEqual(480, CalendarCapacity.DailyCapacity("Capacity Type"::"Work Center", WorkCenterNo(), WorkDate()), 'The effective capacity of the day is summed.');
    end;

    [Test]
    procedure CalculatingIsRefusedWhileTheFeatureIsOff()
    var
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] The feature is off
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        SetFeature(false);

        // [WHEN] The load plan is calculated
        asserterror Engine.Calculate(WorkCenterNo());

        // [THEN] It is refused
        Assert.ExpectedError('is not enabled');
    end;

    [Test]
    procedure ApplyingThePlanIsRefusedUnlessAllowed()
    var
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] The feature is on, but applying the plan to orders is not allowed
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        CreateOperation('MFGL-H', WorkDate() + 1, 100);
        Engine.Calculate(WorkCenterNo());

        // [WHEN] The plan is applied
        asserterror Engine.ApplyPlan(WorkCenterNo());

        // [THEN] It is refused
        Assert.ExpectedError('is not allowed');
    end;

    [Test]
    procedure ApplyingThePlanMovesOnlyTheOperationsThatFit()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
        Locator: Codeunit "MFG Loading Locator";
    begin
        // [GIVEN] Applying is allowed, a one-day horizon of 480 minutes; order I due tomorrow needs 300 minutes and
        // fits, order J due later needs 600 and does not
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 1);
        AllowWriteBack(true);
        CreateOperation('MFGL-I', WorkDate() + 1, 300);
        CreateOperation('MFGL-J', WorkDate() + 5, 600);
        Engine.Calculate(WorkCenterNo());
        TestPlanWriteBack.ResetApplied();
        Locator.ImplementWriteBack(TestPlanWriteBack);

        // [WHEN] The plan is applied, then applied again
        // [THEN] Only I is moved and marked, and the second time nothing is left to move
        Assert.AreEqual(1, Engine.ApplyPlan(WorkCenterNo()), 'Only the operation that fits is moved.');
        Assert.IsTrue(TestPlanWriteBack.WasApplied('MFGL-I'), 'I fits the horizon.');
        Assert.IsFalse(TestPlanWriteBack.WasApplied('MFGL-J'), 'J does not fit, so it is left alone.');
        FindLine(LoadPlanLine, 'MFGL-I');
        Assert.IsTrue(LoadPlanLine."Written Back", 'The moved operation is marked.');
        Assert.AreEqual(LoadPlanLine."Planned Starting Date", LoadPlanLine."Current Starting Date", 'Its current start is now the planned one.');
        Assert.AreEqual(0, Engine.ApplyPlan(WorkCenterNo()), 'An operation is moved once.');

        Locator.ResetWriteBack();
        AllowWriteBack(false);
    end;

    [Test]
    procedure TheRoutingWriteBackLeavesAFinishedOperationAlone()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Loading Engine";
        RoutingWriteBack: Codeunit "MFG Routing Write-Back";
    begin
        // [GIVEN] A planned operation that was finished after the plan was calculated
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        CreateOperation('MFGL-K', WorkDate() + 1, 100);
        Engine.Calculate(WorkCenterNo());
        ProdOrderRoutingLine.Get(ProdOrderRoutingLine.Status::"Firm Planned", 'MFGL-K', 10000, 'MFGL-ROUTING', '10');
        ProdOrderRoutingLine."Routing Status" := ProdOrderRoutingLine."Routing Status"::Finished;
        ProdOrderRoutingLine.Modify(false);

        // [WHEN] The routing write-back is asked to move it
        // [THEN] It refuses without touching the operation, as it does for an operation that no longer exists
        FindLine(LoadPlanLine, 'MFGL-K');
        Assert.IsFalse(RoutingWriteBack.Apply(LoadPlanLine), 'A finished operation is not moved.');
        ProdOrderRoutingLine.Delete(false);
        Assert.IsFalse(RoutingWriteBack.Apply(LoadPlanLine), 'A deleted operation is not moved.');
    end;

    [Test]
    procedure TheNextOperationWaitsForThePreviousOneOnAnotherWorkCenter()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] 480 minutes a day on both work centers; order M runs operation 10 on the first for 960 minutes, then
        // operation 20 on the second for 100 minutes
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        PrepareSecondWorkCenter();
        CreateOperationOn('MFGL-M', WorkDate() + 5, WorkCenterNo(), '10', '', 960);
        CreateOperationOn('MFGL-M', WorkDate() + 5, SecondWorkCenterNo(), '20', '10', 100);

        // [WHEN] All work centers are loaded together
        Engine.CalculateAll();

        // [THEN] Operation 20 starts the day operation 10 ends, although the second work center is free today
        FindOperation(LoadPlanLine, 'MFGL-M', '10');
        Assert.AreEqual(WorkDate() + 1, LoadPlanLine."Planned Ending Date", 'Operation 10 takes two days.');
        FindOperation(LoadPlanLine, 'MFGL-M', '20');
        Assert.AreEqual(WorkDate() + 1, LoadPlanLine."Earliest Start Date", 'Operation 20 can start when operation 10 ends.');
        Assert.AreEqual(WorkDate() + 1, LoadPlanLine."Planned Starting Date", 'Operation 20 waits for operation 10.');
    end;

    [Test]
    procedure AnOperationAfterOneThatDoesNotFitDoesNotFitEither()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] A one-day horizon of 480 minutes; order N runs operation 10 for 600 minutes, then operation 20 for 10
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 1);
        PrepareSecondWorkCenter();
        CreateOperationOn('MFGL-N', WorkDate() + 5, WorkCenterNo(), '10', '', 600);
        CreateOperationOn('MFGL-N', WorkDate() + 5, SecondWorkCenterNo(), '20', '10', 10);

        // [WHEN] All work centers are loaded together
        Engine.CalculateAll();

        // [THEN] Neither fits: operation 20 cannot start before operation 10 is done
        FindOperation(LoadPlanLine, 'MFGL-N', '10');
        Assert.IsFalse(LoadPlanLine."Fits Horizon", 'Operation 10 does not fit.');
        FindOperation(LoadPlanLine, 'MFGL-N', '20');
        Assert.IsFalse(LoadPlanLine."Fits Horizon", 'Operation 20 waits for an operation that does not fit.');
    end;

    [Test]
    procedure OperationsWithoutPreviousOperationsStartAtOnce()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] Order P on the first work center and order Q on the second, unrelated
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        PrepareSecondWorkCenter();
        CreateOperationOn('MFGL-P', WorkDate() + 5, WorkCenterNo(), '10', '', 300);
        CreateOperationOn('MFGL-Q', WorkDate() + 5, SecondWorkCenterNo(), '10', '', 300);

        // [WHEN] All work centers are loaded together
        Engine.CalculateAll();

        // [THEN] Both start today
        FindOperation(LoadPlanLine, 'MFGL-P', '10');
        Assert.AreEqual(WorkDate(), LoadPlanLine."Planned Starting Date", 'P starts today.');
        FindOperation(LoadPlanLine, 'MFGL-Q', '10');
        Assert.AreEqual(WorkDate(), LoadPlanLine."Planned Starting Date", 'Q starts today on its own work center.');
    end;

    [Test]
    procedure MachineCentersOfOneWorkCenterRunInParallel()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] 480 minutes a day on each machine center; order R needs 480 minutes on machine center 1, order S 480
        // on machine center 2, both of the same work center
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        CreateMachineOperation('MFGL-R', WorkDate() + 5, 'MFGL-MC1', 480);
        CreateMachineOperation('MFGL-S', WorkDate() + 6, 'MFGL-MC2', 480);

        // [WHEN] The work center is loaded
        Engine.Calculate(WorkCenterNo());

        // [THEN] Both run today, each on its own machine
        FindLine(LoadPlanLine, 'MFGL-R');
        Assert.AreEqual(WorkDate(), LoadPlanLine."Planned Ending Date", 'R fills machine center 1 today.');
        Assert.AreEqual(LoadPlanLine."Capacity Type"::"Machine Center", LoadPlanLine."Capacity Type", 'R runs on a machine center.');
        FindLine(LoadPlanLine, 'MFGL-S');
        Assert.AreEqual(WorkDate(), LoadPlanLine."Planned Starting Date", 'S does not wait for R: it has its own machine.');
    end;

    [Test]
    procedure AMachineCenterIsLoadedOnItsOwnCapacity()
    var
        LoadPlanLine: Record "MFG Load Plan Line";
        Engine: Codeunit "MFG Loading Engine";
    begin
        // [GIVEN] Machine center 3 has 240 minutes a day, and order T needs 480 minutes on it
        Prepare(Enum::"MFG Sequencing Strategy"::MFGDueDate, 30);
        TestCapacitySource.SetCapacity('MFGL-MC3', 240);
        CreateMachineOperation('MFGL-T', WorkDate() + 5, 'MFGL-MC3', 480);

        // [WHEN] The work center is loaded
        Engine.Calculate(WorkCenterNo());

        // [THEN] It takes two days, although the work center has 480 a day
        FindLine(LoadPlanLine, 'MFGL-T');
        Assert.AreEqual(WorkDate() + 1, LoadPlanLine."Planned Ending Date", 'The machine center''s own capacity is used.');
        TestCapacitySource.ResetCapacities();
    end;

    [Test]
    procedure TheCalendarSourceReadsAMachineCentersEntries()
    var
        CalendarEntry: Record "Calendar Entry";
        CalendarCapacity: Codeunit "MFG Calendar Capacity";
    begin
        // [GIVEN] A calendar entry of 300 today for machine center MFGL-MC9
        CalendarEntry.Init();
        CalendarEntry."Capacity Type" := CalendarEntry."Capacity Type"::"Machine Center";
        CalendarEntry."No." := 'MFGL-MC9';
        CalendarEntry.Date := WorkDate();
        CalendarEntry."Starting Time" := 080000T;
        CalendarEntry."Ending Time" := 130000T;
        CalendarEntry."Capacity (Effective)" := 300;
        CalendarEntry.Insert(false);

        // [WHEN] / [THEN] The machine center's day has 300, the work center of the same number nothing
        Assert.AreEqual(300, CalendarCapacity.DailyCapacity("Capacity Type"::"Machine Center", 'MFGL-MC9', WorkDate()), 'The machine center''s entries are summed.');
        Assert.AreEqual(0, CalendarCapacity.DailyCapacity("Capacity Type"::"Work Center", 'MFGL-MC9', WorkDate()), 'A work center does not see a machine center''s entries.');
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG Loading Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] Step 90 opening the feature setup page
        TempSetupStep.FindFirst();
        Assert.AreEqual(90, TempSetupStep."Step No.", 'Finite loading is the last step.');
        Assert.AreEqual(Page::"MFG Loading Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure ImportingSampleDataBuildsThePackage()
    var
        ConfigPackage: Record "Config. Package";
        DemoLoading: Codeunit "MFG Demo Loading";
    begin
        // [WHEN] The sample data is imported twice
        DemoLoading.Import();
        DemoLoading.Import();

        // [THEN] The configuration package exists
        Assert.IsTrue(ConfigPackage.Get('MFG-LOADING'), 'Importing sample data should build the configuration package.');
    end;

    local procedure WorkCenterNo(): Code[20]
    begin
        exit('MFGL-WC');
    end;

    local procedure Prepare(Strategy: Enum "MFG Sequencing Strategy"; HorizonDays: Integer)
    var
        Setup: Record "MFG Loading Setup";
        CapacityUnitOfMeasure: Record "Capacity Unit of Measure";
        WorkCenter: Record "Work Center";
        LoadPlanLine: Record "MFG Load Plan Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        FeatureSetup: Codeunit "MFG Loading Feature Setup";
        Locator: Codeunit "MFG Loading Locator";
    begin
        Locator.Implement(TestCapacitySource);
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := true;
        Setup.Sequencing := Strategy;
        Setup."Horizon Days" := HorizonDays;
        Setup."Allow Write-Back" := false;
        Setup.Modify(true);

        if not CapacityUnitOfMeasure.Get('MFGL-MIN') then begin
            CapacityUnitOfMeasure.Init();
            CapacityUnitOfMeasure.Code := 'MFGL-MIN';
            CapacityUnitOfMeasure.Type := CapacityUnitOfMeasure.Type::Minutes;
            CapacityUnitOfMeasure.Insert(false);
        end;
        if not WorkCenter.Get(WorkCenterNo()) then begin
            WorkCenter.Init();
            WorkCenter."No." := WorkCenterNo();
            WorkCenter."Unit of Measure Code" := 'MFGL-MIN';
            WorkCenter.Insert(false);
        end;

        LoadPlanLine.DeleteAll();
        ProdOrderRoutingLine.SetRange("Work Center No.", WorkCenterNo());
        ProdOrderRoutingLine.DeleteAll(false);
    end;

    local procedure CreateOperation(OrderNo: Code[20]; DueDate: Date; Minutes: Decimal)
    var
        ProductionOrder: Record "Production Order";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        if not ProductionOrder.Get(ProductionOrder.Status::"Firm Planned", OrderNo) then begin
            ProductionOrder.Init();
            ProductionOrder.Status := ProductionOrder.Status::"Firm Planned";
            ProductionOrder."No." := OrderNo;
            ProductionOrder."Due Date" := DueDate;
            ProductionOrder.Insert(false);
        end;

        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := OrderNo;
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGL-ROUTING';
        ProdOrderRoutingLine."Operation No." := '10';
        ProdOrderRoutingLine.Type := ProdOrderRoutingLine.Type::"Work Center";
        ProdOrderRoutingLine."No." := WorkCenterNo();
        ProdOrderRoutingLine."Work Center No." := WorkCenterNo();
        ProdOrderRoutingLine."Expected Capacity Need" := Minutes * 60000;
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure SecondWorkCenterNo(): Code[20]
    begin
        exit('MFGL-WC2');
    end;

    local procedure PrepareSecondWorkCenter()
    var
        WorkCenter: Record "Work Center";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        if not WorkCenter.Get(SecondWorkCenterNo()) then begin
            WorkCenter.Init();
            WorkCenter."No." := SecondWorkCenterNo();
            WorkCenter."Unit of Measure Code" := 'MFGL-MIN';
            WorkCenter.Insert(false);
        end;
        ProdOrderRoutingLine.SetRange("Work Center No.", SecondWorkCenterNo());
        ProdOrderRoutingLine.DeleteAll(false);
    end;

    local procedure CreateOperationOn(OrderNo: Code[20]; DueDate: Date; OnWorkCenterNo: Code[20]; OperationNo: Code[10]; PreviousOperationNo: Code[30]; Minutes: Decimal)
    var
        ProductionOrder: Record "Production Order";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        if not ProductionOrder.Get(ProductionOrder.Status::"Firm Planned", OrderNo) then begin
            ProductionOrder.Init();
            ProductionOrder.Status := ProductionOrder.Status::"Firm Planned";
            ProductionOrder."No." := OrderNo;
            ProductionOrder."Due Date" := DueDate;
            ProductionOrder.Insert(false);
        end;

        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := OrderNo;
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGL-ROUTING';
        ProdOrderRoutingLine."Operation No." := OperationNo;
        ProdOrderRoutingLine."Previous Operation No." := PreviousOperationNo;
        ProdOrderRoutingLine.Type := ProdOrderRoutingLine.Type::"Work Center";
        ProdOrderRoutingLine."No." := OnWorkCenterNo;
        ProdOrderRoutingLine."Work Center No." := OnWorkCenterNo;
        ProdOrderRoutingLine."Expected Capacity Need" := Minutes * 60000;
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure FindOperation(var LoadPlanLine: Record "MFG Load Plan Line"; OrderNo: Code[20]; OperationNo: Code[10])
    begin
        LoadPlanLine.Reset();
        LoadPlanLine.SetRange("Prod. Order No.", OrderNo);
        LoadPlanLine.SetRange("Operation No.", OperationNo);
        LoadPlanLine.FindFirst();
    end;

    local procedure CreateMachineOperation(OrderNo: Code[20]; DueDate: Date; MachineCenterNo: Code[20]; Minutes: Decimal)
    var
        ProductionOrder: Record "Production Order";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        if not ProductionOrder.Get(ProductionOrder.Status::"Firm Planned", OrderNo) then begin
            ProductionOrder.Init();
            ProductionOrder.Status := ProductionOrder.Status::"Firm Planned";
            ProductionOrder."No." := OrderNo;
            ProductionOrder."Due Date" := DueDate;
            ProductionOrder.Insert(false);
        end;

        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := OrderNo;
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGL-ROUTING';
        ProdOrderRoutingLine."Operation No." := '10';
        ProdOrderRoutingLine.Type := ProdOrderRoutingLine.Type::"Machine Center";
        ProdOrderRoutingLine."No." := MachineCenterNo;
        ProdOrderRoutingLine."Work Center No." := WorkCenterNo();
        ProdOrderRoutingLine."Expected Capacity Need" := Minutes * 60000;
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure FindLine(var LoadPlanLine: Record "MFG Load Plan Line"; OrderNo: Code[20])
    begin
        LoadPlanLine.Reset();
        LoadPlanLine.SetRange("Work Center No.", WorkCenterNo());
        LoadPlanLine.SetRange("Prod. Order No.", OrderNo);
        LoadPlanLine.FindFirst();
    end;

    local procedure AddCalendarEntry(StartingTime: Time; EndingTime: Time; Capacity: Decimal)
    var
        CalendarEntry: Record "Calendar Entry";
    begin
        CalendarEntry.Init();
        CalendarEntry."Capacity Type" := CalendarEntry."Capacity Type"::"Work Center";
        CalendarEntry."No." := WorkCenterNo();
        CalendarEntry.Date := WorkDate();
        CalendarEntry."Starting Time" := StartingTime;
        CalendarEntry."Ending Time" := EndingTime;
        CalendarEntry."Capacity (Effective)" := Capacity;
        CalendarEntry.Insert(false);
    end;

    local procedure AllowWriteBack(Allow: Boolean)
    var
        Setup: Record "MFG Loading Setup";
        FeatureSetup: Codeunit "MFG Loading Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."Allow Write-Back" := Allow;
        Setup.Modify(true);
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Loading Setup";
        FeatureSetup: Codeunit "MFG Loading Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup.Modify(true);
    end;
}
