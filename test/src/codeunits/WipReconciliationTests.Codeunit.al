namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.WIPControl;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;
using System.TestLibraries.Utilities;

codeunit 89020 "MFG WIP Reconciliation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure ADifferenceWithinTheToleranceIsMatched()
    var
        ProductionOrder: Record "Production Order";
        Reconciliation: Record "MFG WIP Reconciliation";
    begin
        // [GIVEN] An order holding 30 of WIP in its value entries, 29.50 in the G/L, and a tolerance of 1
        SetReconciliation(1, 30);
        CreateOrder(ProductionOrder, ProductionOrder.Status::Released, 'MFGR-001', 0D);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Consumption, -30, 0);

        // [WHEN] The order is reconciled against a G/L source holding 29.50
        ReconcileWithFake(ProductionOrder, 29.5, 0);

        // [THEN] It is matched
        Reconciliation.Get(ProductionOrder.Status, ProductionOrder."No.");
        Assert.AreEqual(30, Reconciliation."Value WIP", 'The value WIP is consumption plus capacity minus output.');
        Assert.AreEqual(29.5, Reconciliation."G/L WIP", 'The G/L WIP comes from the G/L source.');
        Assert.AreEqual(0.5, Reconciliation.Difference, 'The difference is value WIP minus G/L WIP.');
        Assert.AreEqual(Reconciliation.Status::MFGMatched, Reconciliation.Status, 'A difference within the tolerance is matched.');
    end;

    [Test]
    procedure CostNotPostedToGLExplainsTheDifference()
    var
        ProductionOrder: Record "Production Order";
        Reconciliation: Record "MFG WIP Reconciliation";
    begin
        // [GIVEN] An order holding 30 of WIP whose cost has not been posted to the G/L yet
        SetReconciliation(1, 30);
        CreateOrder(ProductionOrder, ProductionOrder.Status::Released, 'MFGR-002', 0D);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Consumption, -30, 0);

        // [WHEN] The order is reconciled against a G/L source holding nothing, with 30 not posted
        ReconcileWithFake(ProductionOrder, 0, 30);

        // [THEN] It is marked as not posted to the G/L yet
        Reconciliation.Get(ProductionOrder.Status, ProductionOrder."No.");
        Assert.AreEqual(Reconciliation.Status::MFGNotPostedYet, Reconciliation.Status, 'Unposted cost explains the difference.');
        Assert.AreEqual(30, Reconciliation."Unposted Cost", 'The unposted cost comes from the G/L source.');
    end;

    [Test]
    procedure AnUnexplainedDifferenceNeedsInvestigating()
    var
        ProductionOrder: Record "Production Order";
        Reconciliation: Record "MFG WIP Reconciliation";
    begin
        // [GIVEN] An order holding 30 of WIP, all of it posted to the G/L
        SetReconciliation(1, 30);
        CreateOrder(ProductionOrder, ProductionOrder.Status::Released, 'MFGR-003', 0D);
        AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Consumption, -30, 0);

        // [WHEN] The order is reconciled against a G/L source holding only 10
        ReconcileWithFake(ProductionOrder, 10, 0);

        // [THEN] It needs investigating
        Reconciliation.Get(ProductionOrder.Status, ProductionOrder."No.");
        Assert.AreEqual(20, Reconciliation.Difference, 'The difference is value WIP minus G/L WIP.');
        Assert.AreEqual(Reconciliation.Status::MFGInvestigate, Reconciliation.Status, 'Nothing explains the difference.');
    end;

    [Test]
    procedure ReconcileCoversReleasedAndRecentlyFinishedOrders()
    var
        Released: Record "Production Order";
        RecentlyFinished: Record "Production Order";
        LongFinished: Record "Production Order";
        Reconciliation: Record "MFG WIP Reconciliation";
        TestGLWipSource: Codeunit "MFG Test GL WIP Source";
        Locator: Codeunit "MFG WIP Locator";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] Finished orders are reconciled for 30 days; a released order, one finished 10 days ago and one
        // finished 60 days ago
        SetReconciliation(1, 30);
        CreateOrder(Released, Released.Status::Released, 'MFGR-004', 0D);
        CreateOrder(RecentlyFinished, RecentlyFinished.Status::Finished, 'MFGR-005', WorkDate() - 10);
        CreateOrder(LongFinished, LongFinished.Status::Finished, 'MFGR-006', WorkDate() - 60);

        // [WHEN] The reconciliation runs
        TestGLWipSource.SetAmounts(0, 0);
        Locator.ImplementGLSource(TestGLWipSource);
        Engine.Reconcile();
        Locator.ResetGLSource();

        // [THEN] The released and the recently finished order are reconciled, the old one is not
        Assert.IsTrue(Reconciliation.Get(Released.Status, Released."No."), 'Every released order is reconciled.');
        Assert.IsTrue(Reconciliation.Get(RecentlyFinished.Status, RecentlyFinished."No."), 'An order finished within the period is reconciled.');
        Assert.IsFalse(Reconciliation.Get(LongFinished.Status, LongFinished."No."), 'An order finished before the period is not reconciled.');
    end;

    [Test]
    procedure TheDefaultSourceReadsOnlyTheWipAccounts()
    var
        ProductionOrder: Record "Production Order";
        GLSource: Codeunit "MFG WIP GL Source";
        ValueEntryNo: Integer;
    begin
        // [GIVEN] WIP account MFGR-WIP in the inventory posting setup, and an order whose value entry posted 30 to it
        // and 99 to another account
        AddWipAccount('MFGR-WIP');
        CreateOrder(ProductionOrder, ProductionOrder.Status::Released, 'MFGR-007', 0D);
        ValueEntryNo := AddValueEntry(ProductionOrder."No.", "Item Ledger Entry Type"::Consumption, -50, -20);
        AddGLEntry(ValueEntryNo, 'MFGR-WIP', 30);
        AddGLEntry(ValueEntryNo, 'MFGR-OTHER', 99);

        // [WHEN] The default source reads the order
        // [THEN] Only the WIP account counts, and the unposted cost is actual cost minus cost posted to G/L
        Assert.AreEqual(30, GLSource.GLWipAmount(ProductionOrder), 'Only G/L entries on a WIP account count.');
        Assert.AreEqual(-30, GLSource.UnpostedCost(ProductionOrder), 'The unposted cost is actual cost minus cost posted to G/L.');
    end;

    local procedure ReconcileWithFake(ProductionOrder: Record "Production Order"; GLWip: Decimal; Unposted: Decimal)
    var
        TestGLWipSource: Codeunit "MFG Test GL WIP Source";
        Locator: Codeunit "MFG WIP Locator";
        Engine: Codeunit "MFG WIP Engine";
    begin
        TestGLWipSource.SetAmounts(GLWip, Unposted);
        Locator.ImplementGLSource(TestGLWipSource);
        Engine.ReconcileOrder(ProductionOrder);
        Locator.ResetGLSource();
    end;

    local procedure SetReconciliation(Tolerance: Decimal; Days: Integer)
    var
        Setup: Record "MFG WIP Setup";
    begin
        if not Setup.Get() then begin
            Setup.Init();
            Setup.Insert(false);
        end;
        Setup."Reconciliation Tolerance" := Tolerance;
        Setup."Reconciliation Days" := Days;
        Setup.Modify(false);
    end;

    local procedure CreateOrder(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; OrderNo: Code[20]; FinishedDate: Date)
    begin
        ProductionOrder.Init();
        ProductionOrder.Status := Status;
        ProductionOrder."No." := OrderNo;
        ProductionOrder."Source No." := 'MFGR-OUT';
        ProductionOrder.Quantity := 10;
        ProductionOrder."Finished Date" := FinishedDate;
        ProductionOrder.Insert(false);
    end;

    local procedure AddValueEntry(OrderNo: Code[20]; EntryType: Enum "Item Ledger Entry Type"; CostAmount: Decimal; CostPostedToGL: Decimal): Integer
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
        ValueEntry."Cost Posted to G/L" := CostPostedToGL;
        ValueEntry."Posting Date" := WorkDate();
        ValueEntry.Insert(false);
        exit(ValueEntry."Entry No.");
    end;

    local procedure AddWipAccount(AccountNo: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.Init();
        InventoryPostingSetup."Location Code" := 'MFGR-LOC';
        InventoryPostingSetup."Invt. Posting Group Code" := 'MFGR-GRP';
        InventoryPostingSetup."WIP Account" := AccountNo;
        if not InventoryPostingSetup.Insert(false) then
            InventoryPostingSetup.Modify(false);
    end;

    local procedure AddGLEntry(ValueEntryNo: Integer; AccountNo: Code[20]; Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        EntryNo: Integer;
    begin
        if GLEntry.FindLast() then
            EntryNo := GLEntry."Entry No.";

        GLEntry.Init();
        GLEntry."Entry No." := EntryNo + 1;
        GLEntry."G/L Account No." := AccountNo;
        GLEntry.Amount := Amount;
        GLEntry."Posting Date" := WorkDate();
        GLEntry.Insert(false);

        GLItemLedgerRelation.Init();
        GLItemLedgerRelation."G/L Entry No." := GLEntry."Entry No.";
        GLItemLedgerRelation."Value Entry No." := ValueEntryNo;
        GLItemLedgerRelation.Insert(false);
    end;
}
