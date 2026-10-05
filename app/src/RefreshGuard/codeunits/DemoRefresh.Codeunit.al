namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;

codeunit 85408 "MFG Demo Refresh"
{
    Access = Public;

    var
        DemoOrderNoTok: Label 'MFG-RFP-001', Locked = true;
        PackageCodeTok: Label 'MFG-REFRESH', Locked = true;
        PackageNameLbl: Label 'Manufacturing Advanced - Refresh Protection';

    /// <summary>
    /// Seeds the refresh protection sample data. Idempotent. Creates firm planned order MFG-RFP-001 for the first
    /// certified manufactured item, changes the quantity per of its first component by hand, recalculates the
    /// order as a refresh would, and records the run, so that the change the refresh discarded is shown and can be
    /// restored. Builds the feature's configuration package. On a company without a manufactured item, only the
    /// package is created.
    /// </summary>
    procedure Import()
    begin
        CreateDemoRun();
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

    local procedure CreateDemoRun()
    var
        ProductionOrder: Record "Production Order";
        CreateProdOrderLines: Codeunit "Create Prod. Order Lines";
        Engine: Codeunit "MFG Refresh Engine";
        ItemNo: Code[20];
        RunNo: Integer;
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

        ChangeFirstComponentByHand(ProductionOrder);

        RunNo := Engine.BeginRun(ProductionOrder);
        Clear(CreateProdOrderLines);
        CreateProdOrderLines.Copy(ProductionOrder, 1, '', false);
        Engine.CompleteRun(ProductionOrder, RunNo);
    end;

    local procedure ChangeFirstComponentByHand(ProductionOrder: Record "Production Order")
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        if not ProdOrderComponent.FindFirst() then
            exit;

        ProdOrderComponent.Validate("Quantity per", ProdOrderComponent."Quantity per" + 1);
        ProdOrderComponent.Modify(true);
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

    local procedure CreateConfigPackage()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
    begin
        if not ConfigPackageMgt.CreatePackage(PackageCodeTok, PackageNameLbl) then
            exit;

        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Refresh Run");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Refresh Change");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Refresh Comp. Snapshot");
        ConfigPackageMgt.AddOwnTable(PackageCodeTok, Database::"MFG Refresh Oper. Snapshot");
    end;
}
