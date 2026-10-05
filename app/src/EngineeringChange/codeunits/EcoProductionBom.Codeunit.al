namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;

codeunit 85805 "MFG ECO Production BOM" implements "MFG IEcoObject"
{
    Access = Public;

    /// <summary>
    /// Checks that the production BOM exists and takes its description.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure ValidateNo(var EcoLine: Record "MFG ECO Line")
    var
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        EcoLine.Description := '';
        if EcoLine."No." = '' then
            exit;
        ProductionBOMHeader.SetLoadFields(Description);
        ProductionBOMHeader.Get(EcoLine."No.");
        EcoLine.Description := ProductionBOMHeader.Description;
    end;

    /// <summary>
    /// Creates a version of the production BOM named after the change, under development, as a copy of the version
    /// certified for today (or of the BOM itself when it has none), with the standard Production BOM-Copy.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure CreateVersion(var EcoLine: Record "MFG ECO Line")
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        ProductionBOMCopy: Codeunit "Production BOM-Copy";
        VersionManagement: Codeunit VersionManagement;
        FromVersionCode: Code[20];
    begin
        if EcoLine."New Version Code" <> '' then
            exit;

        ProductionBOMHeader.Get(EcoLine."No.");
        FromVersionCode := VersionManagement.GetBOMVersion(ProductionBOMHeader."No.", WorkDate(), true);

        ProductionBOMVersion.Init();
        ProductionBOMVersion."Production BOM No." := ProductionBOMHeader."No.";
        ProductionBOMVersion."Version Code" := EcoLine."ECO No.";
        ProductionBOMVersion.Description := ProductionBOMHeader.Description;
        ProductionBOMVersion."Unit of Measure Code" := ProductionBOMHeader."Unit of Measure Code";
        ProductionBOMVersion.Status := ProductionBOMVersion.Status::"Under Development";
        ProductionBOMVersion.Insert(true);

        ProductionBOMCopy.CopyBOM(ProductionBOMHeader."No.", FromVersionCode, ProductionBOMHeader, ProductionBOMVersion."Version Code");

        EcoLine."New Version Code" := ProductionBOMVersion."Version Code";
        EcoLine.Modify(true);
    end;

    /// <summary>
    /// Sets the version's starting date to the effective date and certifies it, which runs the standard BOM check.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    /// <param name="EffectiveDate">The date the version takes effect.</param>
    procedure Certify(EcoLine: Record "MFG ECO Line"; EffectiveDate: Date)
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        ProductionBOMVersion.Get(EcoLine."No.", EcoLine."New Version Code");
        ProductionBOMVersion.Validate("Starting Date", EffectiveDate);
        ProductionBOMVersion.Modify(true);
        ProductionBOMVersion.Validate(Status, ProductionBOMVersion.Status::Certified);
    end;

    /// <summary>
    /// Adds every planned, firm planned and released production order line that uses the production BOM.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    /// <param name="TempImpact">The impact buffer.</param>
    procedure CollectImpact(EcoLine: Record "MFG ECO Line"; var TempImpact: Record "MFG ECO Impact" temporary)
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetLoadFields(Status, "Prod. Order No.", "Line No.", "Item No.", Quantity, "Due Date", "Production BOM Version Code");
        ProdOrderLine.SetFilter(Status, '%1|%2|%3', ProdOrderLine.Status::Planned, ProdOrderLine.Status::"Firm Planned", ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Production BOM No.", EcoLine."No.");
        if not ProdOrderLine.FindSet() then
            exit;

        repeat
            TempImpact.Reset();
            if TempImpact.FindLast() then;
            TempImpact.Init();
            TempImpact."Entry No." += 1;
            TempImpact."Object Type" := EcoLine."Object Type";
            TempImpact."Object No." := EcoLine."No.";
            TempImpact."Prod. Order Status" := ProdOrderLine.Status;
            TempImpact."Prod. Order No." := ProdOrderLine."Prod. Order No.";
            TempImpact."Prod. Order Line No." := ProdOrderLine."Line No.";
            TempImpact."Item No." := ProdOrderLine."Item No.";
            TempImpact.Quantity := ProdOrderLine.Quantity;
            TempImpact."Due Date" := ProdOrderLine."Due Date";
            TempImpact."Version In Use" := ProdOrderLine."Production BOM Version Code";
            TempImpact.Insert();
        until ProdOrderLine.Next() = 0;
    end;

    /// <summary>
    /// Opens the new version of the production BOM.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure OpenVersion(EcoLine: Record "MFG ECO Line")
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        if not ProductionBOMVersion.Get(EcoLine."No.", EcoLine."New Version Code") then
            exit;
        Page.Run(Page::"Production BOM Version", ProductionBOMVersion);
    end;
}
