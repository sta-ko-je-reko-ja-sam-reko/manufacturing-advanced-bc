namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.Preflight;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Setup;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89002 "MFG Preflight Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LineNo: Integer;

    [Test]
    procedure RoutingLinkWithoutOperationIsFound()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckRoutingLink: Codeunit "MFG Check Routing Link";
    begin
        // [GIVEN] An order whose component carries a routing link no operation has
        CreateOrder(ProductionOrder, 'MFGT-RL1', '');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', '', "Flushing Method"::Manual, 'MFGT-L1', 1);

        // [WHEN] The routing link check runs
        RunCheck(CheckRoutingLink, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGRoutingLink, TempFinding);

        // [THEN] The component is reported
        Assert.RecordCount(TempFinding, 1);
        TempFinding.FindFirst();
        Assert.AreEqual(10000, TempFinding."Component Line No.", 'The finding should name the component line.');
    end;

    [Test]
    procedure RoutingLinkMatchedByAnOperationIsNotFound()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckRoutingLink: Codeunit "MFG Check Routing Link";
    begin
        // [GIVEN] An order whose component link is carried by an operation of its line
        CreateOrder(ProductionOrder, 'MFGT-RL2', '');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', '', "Flushing Method"::Backward, 'MFGT-L1', 1);
        CreateOperation(ProductionOrder, 'MFGT-L1');

        // [WHEN] The routing link check runs
        RunCheck(CheckRoutingLink, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGRoutingLink, TempFinding);

        // [THEN] Nothing is reported
        Assert.RecordIsEmpty(TempFinding);
    end;

    [Test]
    procedure BackflushedLotComponentWithoutLotIsFound()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckFlushingTracking: Codeunit "MFG Check Flushing Tracking";
    begin
        // [GIVEN] A backward-flushed, lot-tracked component with no lot assigned
        CreateLotItem('MFGT-LOT1');
        CreateOrder(ProductionOrder, 'MFGT-FT1', '');
        CreateComponent(ProductionOrder, 'MFGT-LOT1', '', "Flushing Method"::Backward, '', 5);

        // [WHEN] The flushing tracking check runs
        RunCheck(CheckFlushingTracking, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGFlushingTracking, TempFinding);

        // [THEN] The component is reported
        Assert.RecordCount(TempFinding, 1);
    end;

    [Test]
    procedure BackflushedLotComponentWithItsLotIsNotFound()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckFlushingTracking: Codeunit "MFG Check Flushing Tracking";
    begin
        // [GIVEN] A backward-flushed, lot-tracked component with a lot assigned for its whole quantity
        CreateLotItem('MFGT-LOT2');
        CreateOrder(ProductionOrder, 'MFGT-FT2', '');
        CreateComponent(ProductionOrder, 'MFGT-LOT2', '', "Flushing Method"::Backward, '', 5);
        AssignLot(ProductionOrder, 10000, 'LOT-A', 5);

        // [WHEN] The flushing tracking check runs
        RunCheck(CheckFlushingTracking, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGFlushingTracking, TempFinding);

        // [THEN] Nothing is reported
        Assert.RecordIsEmpty(TempFinding);
    end;

    [Test]
    procedure PartlyAssignedLotIsFound()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckFlushingTracking: Codeunit "MFG Check Flushing Tracking";
    begin
        // [GIVEN] A forward-flushed, lot-tracked component with a lot for only part of its quantity
        CreateLotItem('MFGT-LOT3');
        CreateOrder(ProductionOrder, 'MFGT-FT3', '');
        CreateComponent(ProductionOrder, 'MFGT-LOT3', '', "Flushing Method"::Forward, '', 5);
        AssignLot(ProductionOrder, 10000, 'LOT-A', 2);

        // [WHEN] The flushing tracking check runs
        RunCheck(CheckFlushingTracking, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGFlushingTracking, TempFinding);

        // [THEN] The component is reported
        Assert.RecordCount(TempFinding, 1);
    end;

    [Test]
    procedure ManuallyFlushedLotComponentIsNotChecked()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckFlushingTracking: Codeunit "MFG Check Flushing Tracking";
    begin
        // [GIVEN] A manually flushed, lot-tracked component with no lot assigned
        CreateLotItem('MFGT-LOT4');
        CreateOrder(ProductionOrder, 'MFGT-FT4', '');
        CreateComponent(ProductionOrder, 'MFGT-LOT4', '', "Flushing Method"::Manual, '', 5);

        // [WHEN] The flushing tracking check runs
        RunCheck(CheckFlushingTracking, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGFlushingTracking, TempFinding);

        // [THEN] Nothing is reported, because the lot is entered when consumption is posted by hand
        Assert.RecordIsEmpty(TempFinding);
    end;

    [Test]
    procedure MissingBinsAtABinMandatoryLocationAreFound()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckMissingBin: Codeunit "MFG Check Missing Bin";
    begin
        // [GIVEN] An output line and a component at a location that requires bins, both without a bin
        CreateLocation('MFGT-BIN', true);
        CreateOrder(ProductionOrder, 'MFGT-MB1', 'MFGT-BIN');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', 'MFGT-BIN', "Flushing Method"::Manual, '', 1);

        // [WHEN] The missing bin check runs
        RunCheck(CheckMissingBin, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGMissingBin, TempFinding);

        // [THEN] Both are reported
        Assert.RecordCount(TempFinding, 2);
        TempFinding.SetRange("Component Line No.", 0);
        Assert.RecordCount(TempFinding, 1);
    end;

    [Test]
    procedure NoBinNeededWhereBinsAreNotMandatory()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckMissingBin: Codeunit "MFG Check Missing Bin";
    begin
        // [GIVEN] An output line and a component without bins at a location that does not require them
        CreateLocation('MFGT-NOBIN', false);
        CreateOrder(ProductionOrder, 'MFGT-MB2', 'MFGT-NOBIN');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', 'MFGT-NOBIN', "Flushing Method"::Manual, '', 1);

        // [WHEN] The missing bin check runs
        RunCheck(CheckMissingBin, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGMissingBin, TempFinding);

        // [THEN] Nothing is reported
        Assert.RecordIsEmpty(TempFinding);
    end;

    [Test]
    procedure UncertifiedBomIsFoundAndCertifiedIsNot()
    var
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CheckUncertifiedDesign: Codeunit "MFG Check Uncertified Design";
    begin
        // [GIVEN] An order line calculated from a production BOM that is under development
        CreateBom('MFGT-BOM', ProductionBOMHeader.Status::"Under Development");
        CreateOrder(ProductionOrder, 'MFGT-UC1', '');
        SetLineBom(ProductionOrder, 'MFGT-BOM');

        // [WHEN] The design check runs
        RunCheck(CheckUncertifiedDesign, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGUncertifiedDesign, TempFinding);

        // [THEN] The line is reported
        Assert.RecordCount(TempFinding, 1);

        // [WHEN] The BOM is certified and the check runs again
        ProductionBOMHeader.Get('MFGT-BOM');
        ProductionBOMHeader.Status := ProductionBOMHeader.Status::Certified;
        ProductionBOMHeader.Modify(false);
        RunCheck(CheckUncertifiedDesign, ProductionOrder, Enum::"MFG Preflight Check Type"::MFGUncertifiedDesign, TempFinding);

        // [THEN] Nothing is reported
        Assert.RecordIsEmpty(TempFinding);
    end;

    [Test]
    procedure EnsureChecksCreatesEveryCheckAndKeepsTheUsersSeverity()
    var
        PreflightCheck: Record "MFG Preflight Check";
        Engine: Codeunit "MFG Preflight Engine";
    begin
        // [GIVEN] The checks exist and the user switched one off
        Engine.EnsureChecks();
        PreflightCheck.Get(PreflightCheck.Check::MFGMissingBin);
        PreflightCheck.Severity := PreflightCheck.Severity::MFGOff;
        PreflightCheck.Modify(true);

        // [WHEN] The checks are ensured again
        Engine.EnsureChecks();

        // [THEN] There is one row per check and the user's choice survives
        Assert.RecordCount(PreflightCheck, 4);
        PreflightCheck.Get(PreflightCheck.Check::MFGMissingBin);
        Assert.AreEqual(PreflightCheck.Severity::MFGOff, PreflightCheck.Severity, 'EnsureChecks must not overwrite a severity the user chose.');
        SetSeverity(PreflightCheck.Check::MFGMissingBin, PreflightCheck.Severity::MFGError);
    end;

    [Test]
    procedure TheEngineSkipsAnOffCheckAndAppliesAConfiguredSeverity()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        Engine: Codeunit "MFG Preflight Engine";
    begin
        // [GIVEN] An order with a routing link that leads nowhere
        CreateOrder(ProductionOrder, 'MFGT-EN1', '');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', '', "Flushing Method"::Manual, 'MFGT-L9', 1);

        // [WHEN] The routing link check is off and the engine runs
        SetSeverity(Enum::"MFG Preflight Check Type"::MFGRoutingLink, Enum::"MFG Preflight Severity"::MFGOff);
        Engine.RunChecks(ProductionOrder, TempFinding);

        // [THEN] Nothing is reported for it
        TempFinding.SetRange(Check, TempFinding.Check::MFGRoutingLink);
        Assert.RecordIsEmpty(TempFinding);

        // [WHEN] The routing link check is raised to Error and the engine runs again
        SetSeverity(Enum::"MFG Preflight Check Type"::MFGRoutingLink, Enum::"MFG Preflight Severity"::MFGError);
        Engine.RunChecks(ProductionOrder, TempFinding);

        // [THEN] The finding carries the configured severity
        TempFinding.SetRange(Check, TempFinding.Check::MFGRoutingLink);
        TempFinding.FindFirst();
        Assert.AreEqual(TempFinding.Severity::MFGError, TempFinding.Severity, 'The finding should carry the configured severity.');
        SetSeverity(Enum::"MFG Preflight Check Type"::MFGRoutingLink, Enum::"MFG Preflight Severity"::MFGWarning);
    end;

    [Test]
    procedure StoringFindingsReplacesThePreviousRun()
    var
        ProductionOrder: Record "Production Order";
        Finding: Record "MFG Preflight Finding";
        TempFinding: Record "MFG Preflight Finding" temporary;
        Engine: Codeunit "MFG Preflight Engine";
    begin
        // [GIVEN] An order with one problem
        Engine.EnsureChecks();
        CreateOrder(ProductionOrder, 'MFGT-ST1', '');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', '', "Flushing Method"::Manual, 'MFGT-L9', 1);

        // [WHEN] The checks run and are stored twice
        Engine.RunAndStore(ProductionOrder, TempFinding);
        Engine.RunAndStore(ProductionOrder, TempFinding);

        // [THEN] Only the last run's findings are kept, stamped with the user
        Finding.SetRange("Prod. Order Status", ProductionOrder.Status);
        Finding.SetRange("Prod. Order No.", ProductionOrder."No.");
        Assert.RecordCount(Finding, TempFinding.Count());
        Finding.FindFirst();
        Assert.AreNotEqual('', Finding."Checked By", 'A stored finding should say who ran the checks.');
    end;

    [Test]
    procedure NothingHappensOnReleaseWhileTheFeatureIsOff()
    var
        ProductionOrder: Record "Production Order";
        Reactions: Codeunit "MFG Preflight Reactions";
    begin
        // [GIVEN] The feature is off and an order has a problem configured as an error
        SetFeature(false, true, true);
        PrepareErrorOrder(ProductionOrder, 'MFGT-RE1');

        // [WHEN] The order is about to be released
        Reactions.OnBeforeChangeStatus(ProductionOrder, Enum::"Production Order Status"::Released);

        // [THEN] Nothing stops it, and nothing was stored
        AssertNoStoredFindings(ProductionOrder);
        RestoreRoutingLinkSeverity();
    end;

    [Test]
    procedure ReleaseIsRefusedWhenAnErrorIsFound()
    var
        ProductionOrder: Record "Production Order";
        Reactions: Codeunit "MFG Preflight Reactions";
    begin
        // [GIVEN] The feature is on, blocking on errors, and an order has a problem configured as an error
        SetFeature(true, true, true);
        PrepareErrorOrder(ProductionOrder, 'MFGT-RE2');

        // [WHEN] The order is about to be released
        asserterror Reactions.OnBeforeChangeStatus(ProductionOrder, Enum::"Production Order Status"::Released);

        // [THEN] The release is refused, naming the order
        Assert.ExpectedError('cannot be released');
        Assert.ExpectedError(ProductionOrder."No.");
        RestoreRoutingLinkSeverity();
    end;

    [Test]
    procedure OtherStatusChangesAreNotChecked()
    var
        ProductionOrder: Record "Production Order";
        Reactions: Codeunit "MFG Preflight Reactions";
    begin
        // [GIVEN] The feature is on, blocking on errors, and an order has a problem configured as an error
        SetFeature(true, true, true);
        PrepareErrorOrder(ProductionOrder, 'MFGT-RE3');

        // [WHEN] The order is about to change to Finished
        Reactions.OnBeforeChangeStatus(ProductionOrder, Enum::"Production Order Status"::Finished);

        // [THEN] Nothing stops it, and nothing was stored
        AssertNoStoredFindings(ProductionOrder);
        RestoreRoutingLinkSeverity();
    end;

    [Test]
    [HandlerFunctions('DeclineConfirm')]
    procedure DecliningAWarningStopsTheRelease()
    var
        ProductionOrder: Record "Production Order";
        Reactions: Codeunit "MFG Preflight Reactions";
    begin
        // [GIVEN] The feature is on, asking about warnings, and an order has a warning
        SetFeature(true, true, true);
        CreateOrder(ProductionOrder, 'MFGT-RE4', '');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', '', "Flushing Method"::Manual, 'MFGT-L9', 1);
        SetSeverity(Enum::"MFG Preflight Check Type"::MFGRoutingLink, Enum::"MFG Preflight Severity"::MFGWarning);

        // [WHEN] The order is about to be released and the user declines
        asserterror Reactions.OnBeforeChangeStatus(ProductionOrder, Enum::"Production Order Status"::Released);

        // [THEN] The release stops without a message of its own
        Assert.AreEqual('', GetLastErrorText(), 'Declining should stop the release silently.');
    end;

    [Test]
    [HandlerFunctions('AcceptConfirm')]
    procedure AnErrorOnlyWarnsWhenBlockingIsOff()
    var
        ProductionOrder: Record "Production Order";
        Reactions: Codeunit "MFG Preflight Reactions";
    begin
        // [GIVEN] The feature is on, not blocking on errors, and an order has a problem configured as an error
        SetFeature(true, false, true);
        PrepareErrorOrder(ProductionOrder, 'MFGT-RE5');

        // [WHEN] The order is about to be released and the user accepts the warning
        Reactions.OnBeforeChangeStatus(ProductionOrder, Enum::"Production Order Status"::Released);

        // [THEN] The release goes ahead, and the finding was stored
        AssertStoredFindings(ProductionOrder);
        RestoreRoutingLinkSeverity();
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG Preflight Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] It adds one step that can be switched on and off and opens the feature's setup page
        Assert.RecordCount(TempSetupStep, 1);
        TempSetupStep.FindFirst();
        Assert.IsTrue(TempSetupStep."Has Toggle", 'Release pre-flight can be switched on and off.');
        Assert.AreEqual(Page::"MFG Preflight Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure SwitchingTheFeatureOnMovesTheFingerprint()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Before: Text;
    begin
        // [GIVEN] The feature is off
        SetFeature(false, true, true);
        Before := FeatureMgt.GetEnabledFingerprint();

        // [WHEN] It is switched on
        SetFeature(true, true, true);

        // [THEN] The fingerprint the setup hub compares has moved, so the session would restart
        Assert.AreNotEqual(Before, FeatureMgt.GetEnabledFingerprint(), 'Switching the feature on should move the fingerprint.');
        Assert.IsTrue(FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGPreflight), 'The facade should report the feature as enabled.');
    end;

    [Test]
    procedure ImportingSampleDataTwiceCreatesItOnce()
    var
        PreflightCheck: Record "MFG Preflight Check";
        ProductionOrder: Record "Production Order";
        ConfigPackage: Record "Config. Package";
        DemoPreflight: Codeunit "MFG Demo Preflight";
    begin
        // [WHEN] The sample data is imported twice
        DemoPreflight.Import();
        DemoPreflight.Import();

        // [THEN] The checks, at most one sample order, and the configuration package exist once
        Assert.RecordCount(PreflightCheck, 4);
        ProductionOrder.SetRange("No.", DemoPreflight.DemoOrderNo());
        Assert.IsTrue(ProductionOrder.Count() <= 1, 'The sample order must not be duplicated.');
        Assert.IsTrue(ConfigPackage.Get('MFG-PREFLIGHT'), 'Importing sample data should build the configuration package.');
    end;

    [ConfirmHandler]
    procedure DeclineConfirm(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ConfirmHandler]
    procedure AcceptConfirm(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure RunCheck(PreflightCheck: Interface "MFG IPreflightCheck"; ProductionOrder: Record "Production Order"; Check: Enum "MFG Preflight Check Type"; var TempFinding: Record "MFG Preflight Finding" temporary)
    var
        Collector: Codeunit "MFG Preflight Collector";
    begin
        Collector.SetContext(ProductionOrder, Check, Enum::"MFG Preflight Severity"::MFGWarning);
        PreflightCheck.Run(ProductionOrder, Collector);
        Collector.GetFindings(TempFinding);
    end;

    local procedure CreateOrder(var ProductionOrder: Record "Production Order"; OrderNo: Code[20]; LocationCode: Code[10])
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::"Firm Planned";
        ProductionOrder."No." := OrderNo;
        ProductionOrder."Location Code" := LocationCode;
        ProductionOrder.Insert(false);

        ProdOrderLine.Init();
        ProdOrderLine.Status := ProductionOrder.Status;
        ProdOrderLine."Prod. Order No." := OrderNo;
        ProdOrderLine."Line No." := 10000;
        ProdOrderLine."Item No." := 'MFGT-OUT';
        ProdOrderLine."Location Code" := LocationCode;
        ProdOrderLine."Routing No." := 'MFGT-ROUTING';
        ProdOrderLine."Routing Reference No." := 10000;
        ProdOrderLine.Insert(false);
        LineNo := 0;
    end;

    local procedure CreateComponent(ProductionOrder: Record "Production Order"; ItemNo: Code[20]; LocationCode: Code[10]; FlushingMethod: Enum "Flushing Method"; RoutingLinkCode: Code[10]; RemainingQty: Decimal)
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        LineNo += 10000;
        ProdOrderComponent.Init();
        ProdOrderComponent.Status := ProductionOrder.Status;
        ProdOrderComponent."Prod. Order No." := ProductionOrder."No.";
        ProdOrderComponent."Prod. Order Line No." := 10000;
        ProdOrderComponent."Line No." := LineNo;
        ProdOrderComponent."Item No." := ItemNo;
        ProdOrderComponent."Location Code" := LocationCode;
        ProdOrderComponent."Flushing Method" := FlushingMethod;
        ProdOrderComponent."Routing Link Code" := RoutingLinkCode;
        ProdOrderComponent."Remaining Qty. (Base)" := RemainingQty;
        ProdOrderComponent.Insert(false);
    end;

    local procedure CreateOperation(ProductionOrder: Record "Production Order"; RoutingLinkCode: Code[10])
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := ProductionOrder."No.";
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGT-ROUTING';
        ProdOrderRoutingLine."Operation No." := '10';
        ProdOrderRoutingLine."Routing Link Code" := RoutingLinkCode;
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure CreateLotItem(ItemNo: Code[20])
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if not ItemTrackingCode.Get('MFGT-LOT') then begin
            ItemTrackingCode.Init();
            ItemTrackingCode.Code := 'MFGT-LOT';
            ItemTrackingCode."Lot Specific Tracking" := true;
            ItemTrackingCode.Insert(false);
        end;

        if Item.Get(ItemNo) then
            exit;
        Item.Init();
        Item."No." := ItemNo;
        Item."Item Tracking Code" := ItemTrackingCode.Code;
        Item.Insert(false);
    end;

    local procedure AssignLot(ProductionOrder: Record "Production Order"; ComponentLineNo: Integer; LotNo: Code[50]; Quantity: Decimal)
    var
        ReservationEntry: Record "Reservation Entry";
        EntryNo: Integer;
    begin
        if ReservationEntry.FindLast() then
            EntryNo := ReservationEntry."Entry No.";

        ReservationEntry.Init();
        ReservationEntry."Entry No." := EntryNo + 1;
        ReservationEntry.Positive := false;
        ReservationEntry."Source Type" := Database::"Prod. Order Component";
        ReservationEntry."Source Subtype" := ProductionOrder.Status.AsInteger();
        ReservationEntry."Source ID" := ProductionOrder."No.";
        ReservationEntry."Source Prod. Order Line" := 10000;
        ReservationEntry."Source Ref. No." := ComponentLineNo;
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry."Quantity (Base)" := -Quantity;
        ReservationEntry.Insert(false);
    end;

    local procedure CreateLocation(LocationCode: Code[10]; BinMandatory: Boolean)
    var
        Location: Record Location;
    begin
        if Location.Get(LocationCode) then
            exit;
        Location.Init();
        Location.Code := LocationCode;
        Location."Bin Mandatory" := BinMandatory;
        Location.Insert(false);
    end;

    local procedure CreateBom(BomNo: Code[20]; Status: Enum "BOM Status")
    var
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        if ProductionBOMHeader.Get(BomNo) then
            ProductionBOMHeader.Delete(false);
        ProductionBOMHeader.Init();
        ProductionBOMHeader."No." := BomNo;
        ProductionBOMHeader.Status := Status;
        ProductionBOMHeader.Insert(false);
    end;

    local procedure SetLineBom(ProductionOrder: Record "Production Order"; BomNo: Code[20])
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.Get(ProductionOrder.Status, ProductionOrder."No.", 10000);
        ProdOrderLine."Production BOM No." := BomNo;
        ProdOrderLine."Routing No." := '';
        ProdOrderLine.Modify(false);
    end;

    local procedure SetSeverity(Check: Enum "MFG Preflight Check Type"; Severity: Enum "MFG Preflight Severity")
    var
        PreflightCheck: Record "MFG Preflight Check";
        Engine: Codeunit "MFG Preflight Engine";
    begin
        Engine.EnsureChecks();
        PreflightCheck.Get(Check);
        PreflightCheck.Severity := Severity;
        PreflightCheck.Modify(true);
    end;

    local procedure SetFeature(Enabled: Boolean; BlockOnErrors: Boolean; ConfirmWarnings: Boolean)
    var
        Setup: Record "MFG Preflight Setup";
        FeatureSetup: Codeunit "MFG Preflight Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Check on Release" := true;
        Setup."Block on Errors" := BlockOnErrors;
        Setup."Confirm Warnings" := ConfirmWarnings;
        Setup.Modify(true);
    end;

    local procedure PrepareErrorOrder(var ProductionOrder: Record "Production Order"; OrderNo: Code[20])
    begin
        CreateOrder(ProductionOrder, OrderNo, '');
        CreateComponent(ProductionOrder, 'MFGT-ITEM', '', "Flushing Method"::Manual, 'MFGT-L9', 1);
        SetSeverity(Enum::"MFG Preflight Check Type"::MFGRoutingLink, Enum::"MFG Preflight Severity"::MFGError);
    end;

    local procedure RestoreRoutingLinkSeverity()
    begin
        SetSeverity(Enum::"MFG Preflight Check Type"::MFGRoutingLink, Enum::"MFG Preflight Severity"::MFGWarning);
    end;

    local procedure AssertNoStoredFindings(ProductionOrder: Record "Production Order")
    var
        Finding: Record "MFG Preflight Finding";
    begin
        Finding.SetRange("Prod. Order Status", ProductionOrder.Status);
        Finding.SetRange("Prod. Order No.", ProductionOrder."No.");
        Assert.RecordIsEmpty(Finding);
    end;

    local procedure AssertStoredFindings(ProductionOrder: Record "Production Order")
    var
        Finding: Record "MFG Preflight Finding";
    begin
        Finding.SetRange("Prod. Order Status", ProductionOrder.Status);
        Finding.SetRange("Prod. Order No.", ProductionOrder."No.");
        Assert.RecordIsNotEmpty(Finding);
    end;
}
