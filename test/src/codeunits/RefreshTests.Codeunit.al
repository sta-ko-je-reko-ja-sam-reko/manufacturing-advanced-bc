namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.RefreshGuard;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89007 "MFG Refresh Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure AnUnchangedOrderLeavesNoRun()
    var
        ProductionOrder: Record "Production Order";
        RefreshRun: Record "MFG Refresh Run";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] An order with a component and an operation
        CreateOrder(ProductionOrder, 'MFGR-001');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);
        AddOperation(ProductionOrder, '10', 'WC1', 5);

        // [WHEN] A run is taken and completed with nothing changed in between
        RunNo := Engine.BeginRun(ProductionOrder);

        // [THEN] No change is recorded and the run is removed
        Assert.AreEqual(0, Engine.CompleteRun(ProductionOrder, RunNo), 'Nothing changed.');
        Assert.IsFalse(RefreshRun.Get(RunNo), 'A run without changes should not be kept.');
    end;

    [Test]
    procedure AChangedQuantityPerIsRecorded()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderComponent: Record "Prod. Order Component";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] A component with quantity per 1
        CreateOrder(ProductionOrder, 'MFGR-002');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);

        // [WHEN] The refresh sets it to 2
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderComponent.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 10000);
        ProdOrderComponent."Quantity per" := 2;
        ProdOrderComponent.Modify(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] One restorable change on Quantity per, from 1 to 2
        Change.SetRange("Run No.", RunNo);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(Change."Change Type"::MFGChanged, Change."Change Type", 'A value changed.');
        Assert.AreEqual(ProdOrderComponent.FieldNo("Quantity per"), Change."Field No.", 'The change is on Quantity per.');
        Assert.AreEqual(Format(1), Change."Old Value", 'The value before the refresh.');
        Assert.AreEqual(Format(2), Change."New Value", 'The value after the refresh.');
        Assert.IsTrue(Change.Restorable, 'A component value can be restored.');
    end;

    [Test]
    procedure ARemovedComponentIsRecorded()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderComponent: Record "Prod. Order Component";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] Two components
        CreateOrder(ProductionOrder, 'MFGR-003');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);
        AddComponent(ProductionOrder, 20000, 'MFGR-B', 1);

        // [WHEN] The refresh removes the second
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderComponent.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 20000);
        ProdOrderComponent.Delete(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] One restorable removal
        Change.SetRange("Run No.", RunNo);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(Change."Change Type"::MFGRemoved, Change."Change Type", 'A component was removed.');
        Assert.IsTrue(Change.Restorable, 'A removed component can be re-created.');
    end;

    [Test]
    procedure AnAddedComponentIsRecorded()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] One component
        CreateOrder(ProductionOrder, 'MFGR-004');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);

        // [WHEN] The refresh adds another
        RunNo := Engine.BeginRun(ProductionOrder);
        AddComponent(ProductionOrder, 20000, 'MFGR-C', 3);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] One addition pointing at the new line
        Change.SetRange("Run No.", RunNo);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(Change."Change Type"::MFGAdded, Change."Change Type", 'A component was added.');
        Assert.AreEqual(20000, Change."Current Line No.", 'The change points at the added line.');
    end;

    [Test]
    procedure TheSameItemTwiceIsMatchedByOccurrence()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderComponent: Record "Prod. Order Component";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] The same item twice on one line
        CreateOrder(ProductionOrder, 'MFGR-005');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);
        AddComponent(ProductionOrder, 20000, 'MFGR-A', 4);

        // [WHEN] Only the second changes
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderComponent.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 20000);
        ProdOrderComponent."Quantity per" := 5;
        ProdOrderComponent.Modify(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] Exactly one change, on the second line
        Change.SetRange("Run No.", RunNo);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(20000, Change."Current Line No.", 'The second occurrence changed.');
    end;

    [Test]
    procedure ARunTimeChangeIsRestorableAWorkCentreChangeIsNot()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] An operation on work centre WC1 with run time 5
        CreateOrder(ProductionOrder, 'MFGR-006');
        AddOperation(ProductionOrder, '10', 'WC1', 5);

        // [WHEN] The refresh moves it to WC2 with run time 7
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderRoutingLine.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 'MFGR-ROUTING', '10');
        ProdOrderRoutingLine."No." := 'WC2';
        ProdOrderRoutingLine."Run Time" := 7;
        ProdOrderRoutingLine.Modify(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] Two changes; the run time can be restored, the work centre cannot
        Change.SetRange("Run No.", RunNo);
        Assert.RecordCount(Change, 2);
        Change.SetRange("Field No.", ProdOrderRoutingLine.FieldNo("Run Time"));
        Change.FindFirst();
        Assert.IsTrue(Change.Restorable, 'The run time can be restored.');
        Change.SetRange("Field No.", ProdOrderRoutingLine.FieldNo("No."));
        Change.FindFirst();
        Assert.IsFalse(Change.Restorable, 'Moving an operation back to another work centre is the planner''s call.');
    end;

    [Test]
    procedure ARemovedOperationIsReportedOnly()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] Two operations
        CreateOrder(ProductionOrder, 'MFGR-007');
        AddOperation(ProductionOrder, '10', 'WC1', 5);
        AddOperation(ProductionOrder, '20', 'WC1', 5);

        // [WHEN] The refresh removes the second
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderRoutingLine.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 'MFGR-ROUTING', '20');
        ProdOrderRoutingLine.Delete(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] One removal that cannot be restored
        Change.SetRange("Run No.", RunNo);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(Change."Change Type"::MFGRemoved, Change."Change Type", 'An operation was removed.');
        Assert.IsFalse(Change.Restorable, 'Re-creating an operation is the planner''s call.');
    end;

    [Test]
    procedure RestoringAChangeThatCannotBeRestoredIsRefused()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] The feature is on, and an operation the refresh moved to another work centre
        SetFeature(true);
        CreateOrder(ProductionOrder, 'MFGR-008');
        AddOperation(ProductionOrder, '10', 'WC1', 5);
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderRoutingLine.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 'MFGR-ROUTING', '10');
        ProdOrderRoutingLine."No." := 'WC2';
        ProdOrderRoutingLine.Modify(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [WHEN] The change is restored
        Change.SetRange("Run No.", RunNo);
        Change.FindFirst();
        asserterror Engine.Restore(Change);

        // [THEN] It is refused
        Assert.ExpectedError('cannot be restored');
    end;

    [Test]
    procedure RestoringIsRefusedWhileTheFeatureIsOff()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderComponent: Record "Prod. Order Component";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] The feature is off, and a recorded component change
        SetFeature(false);
        CreateOrder(ProductionOrder, 'MFGR-009');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderComponent.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 10000);
        ProdOrderComponent."Quantity per" := 2;
        ProdOrderComponent.Modify(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [WHEN] The change is restored
        Change.SetRange("Run No.", RunNo);
        Change.FindFirst();
        asserterror Engine.Restore(Change);

        // [THEN] It is refused because the feature is off
        Assert.ExpectedError('is not enabled');
    end;

    [Test]
    procedure RestoringAnAddedComponentDeletesIt()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderComponent: Record "Prod. Order Component";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] The feature is on, and a component the refresh added
        SetFeature(true);
        CreateOrder(ProductionOrder, 'MFGR-010');
        RunNo := Engine.BeginRun(ProductionOrder);
        AddComponent(ProductionOrder, 10000, 'MFGR-C', 3);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [WHEN] The addition is restored
        Change.SetRange("Run No.", RunNo);
        Assert.AreEqual(1, Engine.RestoreAll(Change), 'One change should be restored.');

        // [THEN] The component is gone and the change is marked restored
        Assert.IsFalse(ProdOrderComponent.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 10000), 'The added component should be deleted.');
        Change.FindFirst();
        Assert.IsTrue(Change.Restored, 'The change should be marked restored.');
    end;

    [Test]
    procedure TheReactionsRecordARunOnlyWhileTheFeatureIsOn()
    var
        ProductionOrder: Record "Production Order";
        RefreshRun: Record "MFG Refresh Run";
        ProdOrderComponent: Record "Prod. Order Component";
        Reactions: Codeunit "MFG Refresh Reactions";
    begin
        // [GIVEN] An order with a component
        CreateOrder(ProductionOrder, 'MFGR-011');
        AddComponent(ProductionOrder, 10000, 'MFGR-A', 1);
        ProdOrderComponent.Get(ProductionOrder.Status, ProductionOrder."No.", 10000, 10000);
        RefreshRun.SetRange("Prod. Order No.", ProductionOrder."No.");

        // [WHEN] A refresh changes it while the feature is off
        SetFeature(false);
        Reactions.OnBeforeRefresh(ProductionOrder);
        ProdOrderComponent."Quantity per" := 2;
        ProdOrderComponent.Modify(false);
        Reactions.OnAfterRefresh(ProductionOrder);

        // [THEN] Nothing is recorded
        Assert.RecordIsEmpty(RefreshRun);

        // [WHEN] A refresh changes it again while the feature is on
        SetFeature(true);
        Reactions.OnBeforeRefresh(ProductionOrder);
        ProdOrderComponent."Quantity per" := 3;
        ProdOrderComponent.Modify(false);
        Reactions.OnAfterRefresh(ProductionOrder);

        // [THEN] One run with the change is kept
        Assert.RecordCount(RefreshRun, 1);
        RefreshRun.FindFirst();
        RefreshRun.CalcFields(Changes);
        Assert.AreEqual(1, RefreshRun.Changes, 'The run should hold the change.');
    end;

    [Test]
    procedure AChangedLineQuantityIsRecordedAndRestored()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderLine: Record "Prod. Order Line";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] The feature is on, and an order line whose quantity the planner set to 8
        SetFeature(true);
        CreateOrder(ProductionOrder, 'MFGR-020');
        SetLineQuantity(ProductionOrder, 10000, 8);

        // [WHEN] The refresh sets the quantity back to the header's 10
        RunNo := Engine.BeginRun(ProductionOrder);
        SetLineQuantity(ProductionOrder, 10000, 10);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] One restorable line change on Quantity, and restoring it puts 8 back
        Change.SetRange("Run No.", RunNo);
        Change.SetRange(Kind, Change.Kind::MFGLine);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(ProdOrderLine.FieldNo(Quantity), Change."Field No.", 'The change is on the line quantity.');
        Assert.IsTrue(Change.Restorable, 'A line quantity can be restored.');
        Engine.Restore(Change);
        ProdOrderLine.Get(ProductionOrder.Status, ProductionOrder."No.", 10000);
        Assert.AreEqual(8, ProdOrderLine.Quantity, 'Restoring puts the planner''s quantity back.');
        SetFeature(false);
    end;

    [Test]
    procedure ALineMatchedAfterRenumberingAndAChangedBomIsReportedOnly()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderLine: Record "Prod. Order Line";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] An order line calculated from BOM MFGR-BOM1
        CreateOrder(ProductionOrder, 'MFGR-021');
        ProdOrderLine.Get(ProductionOrder.Status, ProductionOrder."No.", 10000);
        ProdOrderLine."Production BOM No." := 'MFGR-BOM1';
        ProdOrderLine.Modify(false);

        // [WHEN] The refresh recreates the line as line 20000 from BOM MFGR-BOM2
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderLine.Delete(false);
        ProdOrderLine."Line No." := 20000;
        ProdOrderLine."Production BOM No." := 'MFGR-BOM2';
        ProdOrderLine.Insert(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] The line is matched by item, and the BOM change is reported but cannot be restored
        Change.SetRange("Run No.", RunNo);
        Change.SetRange(Kind, Change.Kind::MFGLine);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(Change."Change Type"::MFGChanged, Change."Change Type", 'The recreated line is the same line.');
        Assert.AreEqual(ProdOrderLine.FieldNo("Production BOM No."), Change."Field No.", 'The change is on the BOM.');
        Assert.IsFalse(Change.Restorable, 'Changing the BOM back is the planner''s call.');
    end;

    [Test]
    procedure ARemovedLineIsReportedOnly()
    var
        ProductionOrder: Record "Production Order";
        Change: Record "MFG Refresh Change";
        ProdOrderLine: Record "Prod. Order Line";
        Engine: Codeunit "MFG Refresh Engine";
        RunNo: Integer;
    begin
        // [GIVEN] An order with a second line the planner added for another item
        CreateOrder(ProductionOrder, 'MFGR-022');
        ProdOrderLine.Init();
        ProdOrderLine.Status := ProductionOrder.Status;
        ProdOrderLine."Prod. Order No." := ProductionOrder."No.";
        ProdOrderLine."Line No." := 20000;
        ProdOrderLine."Item No." := 'MFGR-OUT2';
        ProdOrderLine.Insert(false);

        // [WHEN] The refresh removes it
        RunNo := Engine.BeginRun(ProductionOrder);
        ProdOrderLine.Delete(false);
        Engine.CompleteRun(ProductionOrder, RunNo);

        // [THEN] One removal that cannot be restored
        Change.SetRange("Run No.", RunNo);
        Change.SetRange(Kind, Change.Kind::MFGLine);
        Assert.RecordCount(Change, 1);
        Change.FindFirst();
        Assert.AreEqual(Change."Change Type"::MFGRemoved, Change."Change Type", 'A line was removed.');
        Assert.IsFalse(Change.Restorable, 'Re-creating a line is the planner''s call.');
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG Refresh Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] Step 40, with a toggle, opening the feature setup page
        TempSetupStep.FindFirst();
        Assert.AreEqual(40, TempSetupStep."Step No.", 'Refresh protection comes after WIP control.');
        Assert.IsTrue(TempSetupStep."Has Toggle", 'Refresh protection can be switched on and off.');
        Assert.AreEqual(Page::"MFG Refresh Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure ImportingSampleDataTwiceCreatesItOnce()
    var
        ProductionOrder: Record "Production Order";
        RefreshRun: Record "MFG Refresh Run";
        ConfigPackage: Record "Config. Package";
        DemoRefresh: Codeunit "MFG Demo Refresh";
    begin
        // [WHEN] The sample data is imported twice
        DemoRefresh.Import();
        DemoRefresh.Import();

        // [THEN] At most one sample order with at most one run, and the configuration package
        ProductionOrder.SetRange("No.", DemoRefresh.DemoOrderNo());
        Assert.IsTrue(ProductionOrder.Count() <= 1, 'The sample order must not be duplicated.');
        RefreshRun.SetRange("Prod. Order No.", DemoRefresh.DemoOrderNo());
        Assert.IsTrue(RefreshRun.Count() <= 1, 'The sample run must not be duplicated.');
        Assert.IsTrue(ConfigPackage.Get('MFG-REFRESH'), 'Importing sample data should build the configuration package.');
    end;

    local procedure CreateOrder(var ProductionOrder: Record "Production Order"; OrderNo: Code[20])
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::"Firm Planned";
        ProductionOrder."No." := OrderNo;
        ProductionOrder.Insert(false);

        ProdOrderLine.Init();
        ProdOrderLine.Status := ProductionOrder.Status;
        ProdOrderLine."Prod. Order No." := OrderNo;
        ProdOrderLine."Line No." := 10000;
        ProdOrderLine."Item No." := 'MFGR-OUT';
        ProdOrderLine."Routing No." := 'MFGR-ROUTING';
        ProdOrderLine."Routing Reference No." := 10000;
        ProdOrderLine.Insert(false);
    end;

    local procedure AddComponent(ProductionOrder: Record "Production Order"; ComponentLineNo: Integer; ItemNo: Code[20]; QuantityPer: Decimal)
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.Init();
        ProdOrderComponent.Status := ProductionOrder.Status;
        ProdOrderComponent."Prod. Order No." := ProductionOrder."No.";
        ProdOrderComponent."Prod. Order Line No." := 10000;
        ProdOrderComponent."Line No." := ComponentLineNo;
        ProdOrderComponent."Item No." := ItemNo;
        ProdOrderComponent."Quantity per" := QuantityPer;
        ProdOrderComponent.Insert(false);
    end;

    local procedure AddOperation(ProductionOrder: Record "Production Order"; OperationNo: Code[10]; WorkCenterNo: Code[20]; RunTime: Decimal)
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := ProductionOrder."No.";
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGR-ROUTING';
        ProdOrderRoutingLine."Operation No." := OperationNo;
        ProdOrderRoutingLine.Type := "Capacity Type"::"Work Center";
        ProdOrderRoutingLine."No." := WorkCenterNo;
        ProdOrderRoutingLine."Run Time" := RunTime;
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure SetLineQuantity(ProductionOrder: Record "Production Order"; LineNo: Integer; NewQuantity: Decimal)
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.Get(ProductionOrder.Status, ProductionOrder."No.", LineNo);
        ProdOrderLine.Quantity := NewQuantity;
        ProdOrderLine.Modify(false);
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Refresh Setup";
        FeatureSetup: Codeunit "MFG Refresh Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Notify on Changes" := false;
        Setup.Modify(true);
    end;
}
