namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.ShopFloor;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89013 "MFG Shop Floor Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestPosting: Codeunit "MFG Test Shop Floor Posting";

    [Test]
    procedure StartingAnOperationOpensASession()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Session: Record "MFG Shop Floor Session";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] The feature is on and a released order with an operation
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-001');

        // [WHEN] The operation is started
        Session.Get(Engine.StartOperation(ProdOrderRoutingLine));

        // [THEN] A running session for the current user on that operation and order line
        Assert.AreEqual(Session.Status::MFGRunning, Session.Status, 'The session is running.');
        Assert.AreEqual('10', Session."Operation No.", 'The session is on the operation.');
        Assert.AreEqual(10000, Session."Prod. Order Line No.", 'The session knows its order line.');
        Assert.IsTrue(Engine.IsRunning(ProdOrderRoutingLine), 'The operation reports itself running.');
    end;

    [Test]
    procedure StartingTwiceIsRefused()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] A running operation
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-002');
        Engine.StartOperation(ProdOrderRoutingLine);

        // [WHEN] It is started again
        asserterror Engine.StartOperation(ProdOrderRoutingLine);

        // [THEN] It is refused
        Assert.ExpectedError('already have operation');
    end;

    [Test]
    procedure StoppingRecordsTheMinutes()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Session: Record "MFG Shop Floor Session";
        Engine: Codeunit "MFG Shop Floor Engine";
        SessionNo: Integer;
    begin
        // [GIVEN] An operation started 30 minutes ago
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-003');
        SessionNo := Engine.StartOperation(ProdOrderRoutingLine);
        Session.Get(SessionNo);
        Session."Started At" := CurrentDateTime() - 30 * 60000;
        Session.Modify(false);

        // [WHEN] It is stopped
        Engine.StopOperation(ProdOrderRoutingLine);

        // [THEN] The session is stopped with about 30 minutes
        Session.Get(SessionNo);
        Assert.AreEqual(Session.Status::MFGStopped, Session.Status, 'The session is stopped.');
        Assert.IsTrue((Session.Minutes >= 29.9) and (Session.Minutes <= 31), 'About thirty minutes should be recorded.');
    end;

    [Test]
    procedure StoppingAnOperationThatIsNotRunningIsRefused()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] An operation that was never started
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-004');

        // [WHEN] It is stopped
        asserterror Engine.StopOperation(ProdOrderRoutingLine);

        // [THEN] It is refused
        Assert.ExpectedError('is not running');
    end;

    [Test]
    procedure ReportingOutputPostsItWithTheClockedRunTime()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Session: Record "MFG Shop Floor Session";
        Posted: Record "MFG Shop Floor Event";
        ShopFloorEvent: Record "MFG Shop Floor Event";
        Engine: Codeunit "MFG Shop Floor Engine";
        SessionNo: Integer;
    begin
        // [GIVEN] Run time is posted from the clock, and an operation that ran 20 minutes
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-005');
        SessionNo := Engine.StartOperation(ProdOrderRoutingLine);
        Session.Get(SessionNo);
        Session."Started At" := CurrentDateTime() - 20 * 60000;
        Session.Modify(false);
        Engine.StopOperation(ProdOrderRoutingLine);

        // [WHEN] Five good and one scrapped are reported
        ShopFloorEvent.Get(Engine.ReportOperationOutput(ProdOrderRoutingLine, 5, 1, 'MFGS-SCR'));

        // [THEN] One posting with the quantities, the scrap code and the clocked minutes, and the session's run time is used up
        Assert.AreEqual(1, TestPosting.PostedCount(), 'One posting.');
        TestPosting.LastPosted(Posted);
        Assert.AreEqual(5, Posted."Output Quantity", 'The good quantity.');
        Assert.AreEqual(1, Posted."Scrap Quantity", 'The scrap quantity.');
        Assert.AreEqual('MFGS-SCR', Posted."Scrap Code", 'The scrap code.');
        Assert.IsTrue(Posted."Run Minutes" >= 19.9, 'The clocked minutes are posted as run time.');
        Session.Get(SessionNo);
        Assert.IsTrue(Session."Run Time Posted", 'The session''s minutes are not posted twice.');
        Assert.AreEqual(ShopFloorEvent."Output Quantity", 5, 'The event is recorded.');
    end;

    [Test]
    procedure ReportingNothingIsRefused()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] An operation
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-006');

        // [WHEN] Output of zero good and zero scrap is reported
        asserterror Engine.ReportOperationOutput(ProdOrderRoutingLine, 0, 0, '');

        // [THEN] It is refused and nothing is posted
        Assert.ExpectedError('Enter an output quantity');
        Assert.AreEqual(0, TestPosting.PostedCount(), 'Nothing is posted.');
    end;

    [Test]
    procedure ReportingDowntimePostsTheStopTime()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Posted: Record "MFG Shop Floor Event";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] An operation
        Prepare();
        CreateOperation(ProdOrderRoutingLine, 'MFGS-007');

        // [WHEN] 45 minutes of downtime are reported with a stop code
        Engine.ReportDowntime(ProdOrderRoutingLine, 45, 'MFGS-STP');

        // [THEN] A downtime posting with the minutes and the code
        TestPosting.LastPosted(Posted);
        Assert.AreEqual(Posted."Event Type"::MFGDowntime, Posted."Event Type", 'A downtime event.');
        Assert.AreEqual(45, Posted."Stop Minutes", 'The stop minutes.');
        Assert.AreEqual('MFGS-STP', Posted."Stop Code", 'The stop code.');
    end;

    [Test]
    procedure TheTerminalIsRefusedWhileTheFeatureIsOff()
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        // [GIVEN] The feature is off
        Prepare();
        SetFeature(false);
        CreateOperation(ProdOrderRoutingLine, 'MFGS-008');

        // [WHEN] An operation is started
        asserterror Engine.StartOperation(ProdOrderRoutingLine);

        // [THEN] It is refused
        Assert.ExpectedError('is not enabled');
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG Shop Floor Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] Step 70 opening the feature setup page
        TempSetupStep.FindFirst();
        Assert.AreEqual(70, TempSetupStep."Step No.", 'The shop floor terminal comes after planning insight.');
        Assert.AreEqual(Page::"MFG Shop Floor Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure ImportingSampleDataCreatesTheCodesOnce()
    var
        Scrap: Record Scrap;
        Stop: Record Stop;
        ConfigPackage: Record "Config. Package";
        DemoShopFloor: Codeunit "MFG Demo Shop Floor";
    begin
        // [WHEN] The sample data is imported twice
        DemoShopFloor.Import();
        DemoShopFloor.Import();

        // [THEN] The scrap and stop codes and the configuration package exist
        Assert.IsTrue(Scrap.Get('MFG-QUAL'), 'The sample scrap code exists.');
        Assert.IsTrue(Stop.Get('MFG-BRKDN'), 'The sample stop code exists.');
        Assert.IsTrue(ConfigPackage.Get('MFG-SHOPFLOOR'), 'The configuration package exists.');
    end;

    local procedure Prepare()
    var
        Locator: Codeunit "MFG Shop Floor Locator";
    begin
        TestPosting.Reset();
        Locator.Implement(TestPosting);
        SetFeature(true);
    end;

    local procedure CreateOperation(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; OrderNo: Code[20])
    var
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::Released;
        ProductionOrder."No." := OrderNo;
        ProductionOrder.Insert(false);

        ProdOrderLine.Init();
        ProdOrderLine.Status := ProductionOrder.Status;
        ProdOrderLine."Prod. Order No." := OrderNo;
        ProdOrderLine."Line No." := 10000;
        ProdOrderLine."Item No." := 'MFGS-OUT';
        ProdOrderLine."Routing No." := 'MFGS-ROUTING';
        ProdOrderLine."Routing Reference No." := 10000;
        ProdOrderLine.Insert(false);

        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := OrderNo;
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGS-ROUTING';
        ProdOrderRoutingLine."Operation No." := '10';
        ProdOrderRoutingLine."Work Center No." := 'MFGS-WC';
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Shop Floor Setup";
        FeatureSetup: Codeunit "MFG Shop Floor Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Post Run Time" := true;
        Setup.Modify(true);
    end;
}
