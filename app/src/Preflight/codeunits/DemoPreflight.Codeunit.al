namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;

codeunit 85106 "MFG Demo Preflight"
{
    Access = Public;

    var
        DemoOrderNoTok: Label 'MFG-PRE-001', Locked = true;
        DemoRoutingLinkTok: Label 'MFG-DEMO', Locked = true;
        DemoRoutingLinkLbl: Label 'Pre-flight sample: no operation uses it';
        PackageCodeTok: Label 'MFG-PREFLIGHT', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Release Pre-flight';

    /// <summary>
    /// Seeds the release pre-flight sample data. Idempotent: every record has a fixed key and is created
    /// only when missing. Creates the check configuration, a firm planned production order for the first
    /// certified manufactured item in the company with a component whose routing link leads nowhere, runs
    /// the checks on it so findings exist, and builds the feature's configuration package. On a company
    /// without a manufactured item, only the configuration and the package are created.
    /// </summary>
    procedure Import()
    var
        Engine: Codeunit "MFG Preflight Engine";
    begin
        Engine.EnsureChecks();
        CreateDemoOrder();
        CreateConfigPackage();
    end;

    /// <summary>
    /// The number of the sample production order.
    /// </summary>
    /// <returns>The fixed order number.</returns>
    procedure DemoOrderNo(): Code[20]
    begin
        exit(DemoOrderNoTok);
    end;

    local procedure CreateDemoOrder()
    var
        ProductionOrder: Record "Production Order";
        TempFinding: Record "MFG Preflight Finding" temporary;
        CreateProdOrderLines: Codeunit "Create Prod. Order Lines";
        Engine: Codeunit "MFG Preflight Engine";
        ItemNo: Code[20];
    begin
        if ProductionOrder.Get(ProductionOrder.Status::"Firm Planned", DemoOrderNoTok) then
            exit;
        if not FindManufacturedItem(ItemNo) then
            exit;

        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::"Firm Planned";
        ProductionOrder."No." := DemoOrderNoTok;
        ProductionOrder.Insert(true);
        ProductionOrder.Validate("Source Type", ProductionOrder."Source Type"::Item);
        ProductionOrder.Validate("Source No.", ItemNo);
        ProductionOrder.Validate(Quantity, 1);
        ProductionOrder.Modify(true);

        CreateProdOrderLines.Copy(ProductionOrder, 1, '', false);
        PlantRoutingLinkProblem(ProductionOrder);

        Engine.RunAndStore(ProductionOrder, TempFinding);
    end;

    local procedure FindManufacturedItem(var ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        Item.SetLoadFields("No.", "Production BOM No.");
        Item.SetRange("Replenishment System", Item."Replenishment System"::"Prod. Order");
        Item.SetFilter("Production BOM No.", '<>%1', '');
        Item.SetRange(Blocked, false);
        if not Item.FindSet() then
            exit(false);

        repeat
            ProductionBOMHeader.SetLoadFields(Status);
            if ProductionBOMHeader.Get(Item."Production BOM No.") then
                if ProductionBOMHeader.Status = ProductionBOMHeader.Status::Certified then begin
                    ItemNo := Item."No.";
                    exit(true);
                end;
        until Item.Next() = 0;
        exit(false);
    end;

    local procedure PlantRoutingLinkProblem(ProductionOrder: Record "Production Order")
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        EnsureRoutingLink();

        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        if not ProdOrderComponent.FindFirst() then
            exit;

        ProdOrderComponent.Validate("Routing Link Code", DemoRoutingLinkTok);
        ProdOrderComponent.Modify(true);
    end;

    local procedure EnsureRoutingLink()
    var
        RoutingLink: Record "Routing Link";
    begin
        if RoutingLink.Get(DemoRoutingLinkTok) then
            exit;

        RoutingLink.Init();
        RoutingLink.Code := DemoRoutingLinkTok;
        RoutingLink.Description := CopyStr(DemoRoutingLinkLbl, 1, MaxStrLen(RoutingLink.Description));
        RoutingLink.Insert(true);
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Preflight Check");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Preflight Finding");
    end;
}
