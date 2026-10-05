namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Preflight;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using System.TestLibraries.Utilities;

codeunit 89003 "MFG Preflight Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";

    [Test]
    procedure ReleasingAnOrderWithAnErrorIsRefused()
    var
        ProductionOrder: Record "Production Order";
    begin
        // [GIVEN] Pre-flight is on and blocking, and a refreshed firm planned order has a component whose
        // routing link no operation carries, with that check raised to Error
        SetFeature(true, true);
        SetRoutingLinkSeverity(Enum::"MFG Preflight Severity"::MFGError);
        CreateRefreshedOrderWithDeadRoutingLink(ProductionOrder);

        // [WHEN] The order is released through the standard status change
        asserterror LibraryManufacturing.ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Released, WorkDate(), false);

        // [THEN] The release is refused and the order is still firm planned
        Assert.ExpectedError('cannot be released');
        Assert.IsTrue(ProductionOrder.Get(ProductionOrder.Status::"Firm Planned", ProductionOrder."No."), 'The order should still be firm planned.');
        SetRoutingLinkSeverity(Enum::"MFG Preflight Severity"::MFGWarning);
    end;

    [Test]
    procedure ReleasingTheSameOrderWorksWhenThePreflightIsOff()
    var
        ProductionOrder: Record "Production Order";
        ReleasedOrder: Record "Production Order";
    begin
        // [GIVEN] The same order, but pre-flight is switched off
        SetFeature(false, true);
        SetRoutingLinkSeverity(Enum::"MFG Preflight Severity"::MFGError);
        CreateRefreshedOrderWithDeadRoutingLink(ProductionOrder);

        // [WHEN] The order is released through the standard status change
        LibraryManufacturing.ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Released, WorkDate(), false);

        // [THEN] Standard Business Central releases it
        ReleasedOrder.SetRange(Status, ReleasedOrder.Status::Released);
        ReleasedOrder.SetRange("Source No.", ProductionOrder."Source No.");
        Assert.RecordIsNotEmpty(ReleasedOrder);
        SetRoutingLinkSeverity(Enum::"MFG Preflight Severity"::MFGWarning);
    end;

    [Test]
    procedure ACleanOrderIsReleasedWithThePreflightOn()
    var
        ProductionOrder: Record "Production Order";
        ReleasedOrder: Record "Production Order";
        ParentItem: Record Item;
    begin
        // [GIVEN] Pre-flight is on and blocking, and a refreshed order with nothing wrong with it
        SetFeature(true, true);
        CreateManufacturedItem(ParentItem);
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, ProductionOrder.Status::"Firm Planned", ProductionOrder."Source Type"::Item, ParentItem."No.", 1);
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);

        // [WHEN] The order is released through the standard status change
        LibraryManufacturing.ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Released, WorkDate(), false);

        // [THEN] It is released
        ReleasedOrder.SetRange(Status, ReleasedOrder.Status::Released);
        ReleasedOrder.SetRange("Source No.", ParentItem."No.");
        Assert.RecordIsNotEmpty(ReleasedOrder);
    end;

    local procedure CreateRefreshedOrderWithDeadRoutingLink(var ProductionOrder: Record "Production Order")
    var
        ParentItem: Record Item;
        ProdOrderComponent: Record "Prod. Order Component";
        RoutingLink: Record "Routing Link";
    begin
        CreateManufacturedItem(ParentItem);
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, ProductionOrder.Status::"Firm Planned", ProductionOrder."Source Type"::Item, ParentItem."No.", 1);
        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);

        LibraryManufacturing.CreateRoutingLink(RoutingLink);
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.FindFirst();
        ProdOrderComponent.Validate("Routing Link Code", RoutingLink.Code);
        ProdOrderComponent.Modify(true);
    end;

    local procedure CreateManufacturedItem(var ParentItem: Record Item)
    var
        ComponentItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        LibraryInventory.CreateItem(ComponentItem);
        LibraryInventory.CreateItem(ParentItem);
        LibraryManufacturing.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItem."No.", 1);
        ParentItem.Validate("Replenishment System", ParentItem."Replenishment System"::"Prod. Order");
        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify(true);
    end;

    local procedure SetFeature(Enabled: Boolean; BlockOnErrors: Boolean)
    var
        Setup: Record "MFG Preflight Setup";
        FeatureSetup: Codeunit "MFG Preflight Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Check on Release" := true;
        Setup."Block on Errors" := BlockOnErrors;
        Setup."Confirm Warnings" := false;
        Setup.Modify(true);
    end;

    local procedure SetRoutingLinkSeverity(Severity: Enum "MFG Preflight Severity")
    var
        PreflightCheck: Record "MFG Preflight Check";
        Engine: Codeunit "MFG Preflight Engine";
    begin
        Engine.EnsureChecks();
        PreflightCheck.Get(PreflightCheck.Check::MFGRoutingLink);
        PreflightCheck.Severity := Severity;
        PreflightCheck.Modify(true);
    end;
}
