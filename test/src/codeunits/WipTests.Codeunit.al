namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.WIPControl;
using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;
using Microsoft.Warehouse.Activity;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89004 "MFG WIP Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure AnOrderWithCompleteOutputIsProposed()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] A released order whose output is complete, last posted five days before the work date
        SetMinDays(0);
        CreateReleasedOrder(ProductionOrder, 'MFGW-001', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate() - 5);

        // [WHEN] The order is evaluated
        // [THEN] It is proposed, ready, five days after its last output
        Assert.IsTrue(Engine.EvaluateOrder(ProductionOrder), 'An order with complete output should be proposed.');
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGReady, Proposal.Status, 'Nothing is wrong with the order, so it is ready.');
        Assert.AreEqual(5, Proposal."Days Since Output", 'The days since output count to the work date.');
        Assert.AreEqual(10, Proposal."Finished Quantity", 'The finished quantity comes from the order lines.');
    end;

    [Test]
    procedure AnOrderWithOutputMissingIsNotProposed()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] A released order with one unit still to output
        SetMinDays(0);
        CreateReleasedOrder(ProductionOrder, 'MFGW-002', 10, 1);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 108, WorkDate());

        // [WHEN] The order is evaluated
        // [THEN] It is not proposed
        Assert.IsFalse(Engine.EvaluateOrder(ProductionOrder), 'An order with output still missing is not finished from here.');
        Assert.IsFalse(Proposal.Get(ProductionOrder."No."), 'No proposal should exist for it.');
    end;

    [Test]
    procedure TheMinimumDaysSinceOutputAreRespected()
    var
        ProductionOrder: Record "Production Order";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] Proposals need ten days since the last output, and an order last output five days ago
        SetMinDays(10);
        CreateReleasedOrder(ProductionOrder, 'MFGW-003', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate() - 5);

        // [WHEN] The order is evaluated
        // [THEN] It is not proposed yet
        Assert.IsFalse(Engine.EvaluateOrder(ProductionOrder), 'The order is too recent to propose.');
        SetMinDays(0);
    end;

    [Test]
    procedure WipIsConsumptionPlusCapacityMinusOutput()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] An order that consumed 100, posted 50 of capacity and valued its output at 120
        SetMinDays(0);
        CreateReleasedOrder(ProductionOrder, 'MFGW-004', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Consumption, -100, WorkDate());
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::" ", 50, WorkDate());
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());

        // [WHEN] The order is evaluated
        Engine.EvaluateOrder(ProductionOrder);

        // [THEN] 30 is still in work in progress
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(100, Proposal."Consumption Cost", 'Consumption cost is the cost that left inventory.');
        Assert.AreEqual(50, Proposal."Capacity Cost", 'Capacity cost is what was posted on the order.');
        Assert.AreEqual(120, Proposal."Output Cost", 'Output cost is the value of the output so far.');
        Assert.AreEqual(30, Proposal."Est. WIP Amount", 'WIP is consumption plus capacity minus output.');
    end;

    [Test]
    procedure MissingConsumptionBlocksTheOrder()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] An order with complete output and a component with two units still to consume
        PrepareChecks();
        CreateReleasedOrder(ProductionOrder, 'MFGW-005', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());
        AddComponent(ProductionOrder, 'MFGW-COMP', 2);

        // [WHEN] The order is evaluated
        Engine.EvaluateOrder(ProductionOrder);

        // [THEN] It is blocked, and the notes name the component
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGBlocked, Proposal.Status, 'Missing consumption blocks by default.');
        Assert.IsTrue(StrPos(Proposal.Notes, 'MFGW-COMP') > 0, 'The notes should name the component.');
    end;

    [Test]
    procedure AnOpenPickBlocksTheOrder()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] An order with complete output and an open pick line for its components
        PrepareChecks();
        CreateReleasedOrder(ProductionOrder, 'MFGW-006', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());
        AddPickLine(ProductionOrder);

        // [WHEN] The order is evaluated
        Engine.EvaluateOrder(ProductionOrder);

        // [THEN] It is blocked
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGBlocked, Proposal.Status, 'An open pick blocks by default.');
    end;

    [Test]
    procedure AnUnfinishedOperationOnlyInforms()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] An order with complete output and an operation still in progress
        PrepareChecks();
        CreateReleasedOrder(ProductionOrder, 'MFGW-007', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());
        AddOperation(ProductionOrder, "Prod. Order Routing Status"::"In Progress");

        // [WHEN] The order is evaluated
        Engine.EvaluateOrder(ProductionOrder);

        // [THEN] It is ready, with a note about the operation
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGReady, Proposal.Status, 'An unfinished operation only informs by default.');
        Assert.AreNotEqual('', Proposal.Notes, 'The note should say an operation is not finished.');
    end;

    [Test]
    procedure ACheckSwitchedOffIsIgnored()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] The missing consumption check is off, and an order with consumption missing
        PrepareChecks();
        SetSeverity(Enum::"MFG Finish Check Type"::MFGMissingConsumption, Enum::"MFG Finish Check Severity"::MFGOff);
        CreateReleasedOrder(ProductionOrder, 'MFGW-008', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());
        AddComponent(ProductionOrder, 'MFGW-COMP', 2);

        // [WHEN] The order is evaluated
        Engine.EvaluateOrder(ProductionOrder);

        // [THEN] It is ready with no notes
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGReady, Proposal.Status, 'A check that is off does not block.');
        Assert.AreEqual('', Proposal.Notes, 'A check that is off adds no note.');
        SetSeverity(Enum::"MFG Finish Check Type"::MFGMissingConsumption, Enum::"MFG Finish Check Severity"::MFGBlock);
    end;

    [Test]
    procedure TheValuationCanBeReplaced()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        TestWipValuation: Codeunit "MFG Test WIP Valuation";
        Locator: Codeunit "MFG WIP Locator";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] Another valuation is implemented through the locator
        SetMinDays(0);
        Locator.Implement(TestWipValuation);
        CreateReleasedOrder(ProductionOrder, 'MFGW-009', 10, 0);

        // [WHEN] The order is evaluated
        Engine.EvaluateOrder(ProductionOrder);
        Locator.ResetValuation();

        // [THEN] The proposal carries the replacement's value
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(999, Proposal."Est. WIP Amount", 'The injected valuation should be used.');
    end;

    [Test]
    procedure SuggestRebuildsTheProposals()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] A stale proposal for an order that no longer exists, and a real candidate
        SetMinDays(0);
        Proposal.Init();
        Proposal."Prod. Order No." := 'MFGW-OLD';
        Proposal.Insert(false);
        CreateReleasedOrder(ProductionOrder, 'MFGW-010', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());

        // [WHEN] The proposals are suggested
        Engine.Suggest();

        // [THEN] The stale one is gone and the candidate is there
        Assert.IsFalse(Proposal.Get('MFGW-OLD'), 'A proposal for an order that is gone should be removed.');
        Assert.IsTrue(Proposal.Get(ProductionOrder."No."), 'The candidate should be proposed.');
    end;

    [Test]
    procedure FinishingABlockedOrderIsRefused()
    var
        ProductionOrder: Record "Production Order";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] An order with complete output and consumption missing
        PrepareChecks();
        CreateReleasedOrder(ProductionOrder, 'MFGW-011', 10, 0);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Output, 120, WorkDate());
        AddComponent(ProductionOrder, 'MFGW-COMP', 2);

        // [WHEN] It is finished directly, as the API does
        asserterror Engine.FinishOrder(ProductionOrder);

        // [THEN] It is refused with what the checks found
        Assert.ExpectedError('cannot be finished from WIP control');
    end;

    [Test]
    procedure FinishingAnOrderWithOutputMissingIsRefused()
    var
        ProductionOrder: Record "Production Order";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] An order with output still missing
        SetMinDays(0);
        CreateReleasedOrder(ProductionOrder, 'MFGW-012', 10, 3);

        // [WHEN] It is finished directly
        asserterror Engine.FinishOrder(ProductionOrder);

        // [THEN] It is refused
        Assert.ExpectedError('is not ready to be finished');
    end;

    [Test]
    procedure EnsureChecksKeepsTheUsersSeverity()
    var
        FinishCheck: Record "MFG Finish Check";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] The checks exist and the user changed one
        Engine.EnsureChecks();
        SetSeverity(Enum::"MFG Finish Check Type"::MFGUnfinishedOperations, Enum::"MFG Finish Check Severity"::MFGBlock);

        // [WHEN] They are ensured again
        Engine.EnsureChecks();

        // [THEN] One row per check, and the user's choice survives
        Assert.RecordCount(FinishCheck, 3);
        FinishCheck.Get(FinishCheck.Check::MFGUnfinishedOperations);
        Assert.AreEqual(FinishCheck.Severity::MFGBlock, FinishCheck.Severity, 'EnsureChecks must not overwrite the user''s choice.');
        SetSeverity(Enum::"MFG Finish Check Type"::MFGUnfinishedOperations, Enum::"MFG Finish Check Severity"::MFGInform);
    end;

    [Test]
    procedure TheFeatureRegistersAGuidedSetupStep()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        FeatureSetup: Codeunit "MFG WIP Feature Setup";
    begin
        // [WHEN] The feature is asked for its guided setup step
        FeatureSetup.RegisterStep(TempSetupStep);

        // [THEN] It adds step 30, which can be switched on and off and opens the feature setup page
        TempSetupStep.FindFirst();
        Assert.AreEqual(30, TempSetupStep."Step No.", 'WIP control comes after release pre-flight.');
        Assert.IsTrue(TempSetupStep."Has Toggle", 'WIP control can be switched on and off.');
        Assert.AreEqual(Page::"MFG WIP Setup", TempSetupStep."Setup Page ID", 'The step should open the feature setup page.');
    end;

    [Test]
    procedure ImportingSampleDataTwiceCreatesItOnce()
    var
        FinishCheck: Record "MFG Finish Check";
        ConfigPackage: Record "Config. Package";
        DemoWip: Codeunit "MFG Demo WIP";
    begin
        // [WHEN] The sample data is imported twice
        DemoWip.Import();
        DemoWip.Import();

        // [THEN] The checks and the configuration package exist once
        Assert.RecordCount(FinishCheck, 3);
        Assert.IsTrue(ConfigPackage.Get('MFG-WIP'), 'Importing sample data should build the configuration package.');
    end;

    local procedure CreateReleasedOrder(var ProductionOrder: Record "Production Order"; OrderNo: Code[20]; Qty: Decimal; RemainingQty: Decimal)
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::Released;
        ProductionOrder."No." := OrderNo;
        ProductionOrder."Source No." := 'MFGW-OUT';
        ProductionOrder.Quantity := Qty;
        ProductionOrder.Insert(false);

        ProdOrderLine.Init();
        ProdOrderLine.Status := ProductionOrder.Status;
        ProdOrderLine."Prod. Order No." := OrderNo;
        ProdOrderLine."Line No." := 10000;
        ProdOrderLine."Item No." := 'MFGW-OUT';
        ProdOrderLine.Quantity := Qty;
        ProdOrderLine."Finished Quantity" := Qty - RemainingQty;
        ProdOrderLine."Remaining Quantity" := RemainingQty;
        ProdOrderLine.Insert(false);
    end;

    local procedure AddValueEntry(OrderNo: Code[20]; EntryType: Enum "Item Ledger Entry Type"; CostAmount: Decimal; PostingDate: Date)
    var
        ValueEntry: Record "Value Entry";
        EntryNo: Integer;
    begin
        if ValueEntry.FindLast() then
            EntryNo := ValueEntry."Entry No.";

        ValueEntry.Init();
        ValueEntry."Entry No." := EntryNo + 1;
        ValueEntry."Order Type" := "Inventory Order Type"::Production;
        ValueEntry."Order No." := OrderNo;
        ValueEntry."Item Ledger Entry Type" := EntryType;
        ValueEntry."Cost Amount (Actual)" := CostAmount;
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry.Insert(false);
    end;

    local procedure AddComponent(ProductionOrder: Record "Production Order"; ItemNo: Code[20]; RemainingQty: Decimal)
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.Init();
        ProdOrderComponent.Status := ProductionOrder.Status;
        ProdOrderComponent."Prod. Order No." := ProductionOrder."No.";
        ProdOrderComponent."Prod. Order Line No." := 10000;
        ProdOrderComponent."Line No." := 10000;
        ProdOrderComponent."Item No." := ItemNo;
        ProdOrderComponent."Remaining Quantity" := RemainingQty;
        ProdOrderComponent.Insert(false);
    end;

    local procedure AddPickLine(ProductionOrder: Record "Production Order")
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        WarehouseActivityLine.Init();
        WarehouseActivityLine."Activity Type" := WarehouseActivityLine."Activity Type"::Pick;
        WarehouseActivityLine."No." := 'MFGW-PICK';
        WarehouseActivityLine."Line No." := 10000;
        WarehouseActivityLine."Source Type" := Database::"Prod. Order Component";
        WarehouseActivityLine."Source Subtype" := ProductionOrder.Status.AsInteger();
        WarehouseActivityLine."Source No." := ProductionOrder."No.";
        WarehouseActivityLine.Insert(false);
    end;

    local procedure AddOperation(ProductionOrder: Record "Production Order"; RoutingStatus: Enum "Prod. Order Routing Status")
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.Init();
        ProdOrderRoutingLine.Status := ProductionOrder.Status;
        ProdOrderRoutingLine."Prod. Order No." := ProductionOrder."No.";
        ProdOrderRoutingLine."Routing Reference No." := 10000;
        ProdOrderRoutingLine."Routing No." := 'MFGW-ROUTING';
        ProdOrderRoutingLine."Operation No." := '10';
        ProdOrderRoutingLine."Routing Status" := RoutingStatus;
        ProdOrderRoutingLine.Insert(false);
    end;

    local procedure PrepareChecks()
    var
        Engine: Codeunit "MFG WIP Engine";
    begin
        SetMinDays(0);
        Engine.EnsureChecks();
    end;

    local procedure SetSeverity(Check: Enum "MFG Finish Check Type"; Severity: Enum "MFG Finish Check Severity")
    var
        FinishCheck: Record "MFG Finish Check";
        Engine: Codeunit "MFG WIP Engine";
    begin
        Engine.EnsureChecks();
        FinishCheck.Get(Check);
        FinishCheck.Severity := Severity;
        FinishCheck.Modify(true);
    end;

    local procedure SetMinDays(MinDays: Integer)
    var
        Setup: Record "MFG WIP Setup";
        FeatureSetup: Codeunit "MFG WIP Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."Min. Days Since Output" := MinDays;
        Setup.Modify(true);
    end;
}
