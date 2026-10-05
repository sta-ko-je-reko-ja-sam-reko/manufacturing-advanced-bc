namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.WIPControl;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using System.TestLibraries.Utilities;

codeunit 89005 "MFG WIP Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";

    [Test]
    procedure AnOrderWithConsumptionAndOutputPostedIsFinished()
    var
        ProductionOrder: Record "Production Order";
        FinishedOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] A released order whose component was consumed and whose output was posted in full
        SetMinDays(0);
        CreatePostedOrder(ProductionOrder, true);

        // [WHEN] Its proposal is calculated, selected and finished
        Assert.IsTrue(Engine.EvaluateOrder(ProductionOrder), 'The order should be proposed.');
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGReady, Proposal.Status, 'Nothing is missing, so the order is ready.');
        Proposal.Selected := true;
        Proposal.Modify(true);
        Assert.AreEqual(1, Engine.FinishSelected(), 'One order should have been finished.');

        // [THEN] The order is finished and the proposal says so
        Assert.IsTrue(FinishedOrder.Get(FinishedOrder.Status::Finished, ProductionOrder."No."), 'The order should be finished.');
        Proposal.Get(ProductionOrder."No.");
        Assert.AreEqual(Proposal.Status::MFGFinished, Proposal.Status, 'The proposal should record the finish.');
    end;

    [Test]
    procedure AnOrderWithConsumptionMissingIsNotFinished()
    var
        ProductionOrder: Record "Production Order";
        Proposal: Record "MFG Finish Proposal";
        Engine: Codeunit "MFG WIP Engine";
    begin
        // [GIVEN] A released order whose output was posted but whose component was never consumed
        SetMinDays(0);
        Engine.EnsureChecks();
        CreatePostedOrder(ProductionOrder, false);

        // [WHEN] Its proposal is calculated, selected and Finish selected is chosen
        Engine.EvaluateOrder(ProductionOrder);
        Proposal.Get(ProductionOrder."No.");
        Proposal.Selected := true;
        Proposal.Modify(true);

        // [THEN] It is blocked, nothing is finished, and the order stays released
        Assert.AreEqual(Proposal.Status::MFGBlocked, Proposal.Status, 'Missing consumption should block.');
        Assert.AreEqual(0, Engine.FinishSelected(), 'A blocked order must not be finished.');
        Assert.IsTrue(ProductionOrder.Get(ProductionOrder.Status::Released, ProductionOrder."No."), 'The order should still be released.');
    end;

    local procedure CreatePostedOrder(var ProductionOrder: Record "Production Order"; PostConsumption: Boolean)
    var
        ComponentItem: Record Item;
        ParentItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        LibraryInventory.CreateItem(ComponentItem);
        LibraryInventory.CreateItem(ParentItem);
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItem."No.", 1);
        ParentItem.Validate("Replenishment System", ParentItem."Replenishment System"::"Prod. Order");
        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify(true);

        LibraryManufacturing.CreateProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProductionOrder."Source Type"::Item, ParentItem."No.", 1);
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);

        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.FindFirst();

        if PostConsumption then begin
            LibraryInventory.PostPositiveAdjustment(ComponentItem, '', '', '', 1, WorkDate(), 10);
            LibraryManufacturing.PostConsumption(ProdOrderLine, ComponentItem, '', '', 1, WorkDate(), 10);
        end;
        LibraryManufacturing.PostOutput(ProdOrderLine, 1, WorkDate(), 10);
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
