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
        Assert.AreEqual(480, CalendarCapacity.DailyCapacity(WorkCenterNo(), WorkDate()), 'The effective capacity of the day is summed.');
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
