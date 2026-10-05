namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;

codeunit 85806 "MFG ECO Routing" implements "MFG IEcoObject"
{
    Access = Public;

    /// <summary>
    /// Checks that the routing exists and takes its description.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure ValidateNo(var EcoLine: Record "MFG ECO Line")
    var
        RoutingHeader: Record "Routing Header";
    begin
        EcoLine.Description := '';
        if EcoLine."No." = '' then
            exit;
        RoutingHeader.SetLoadFields(Description);
        RoutingHeader.Get(EcoLine."No.");
        EcoLine.Description := RoutingHeader.Description;
    end;

    /// <summary>
    /// Creates a version of the routing named after the change, under development, as a copy of the version
    /// certified for today (or of the routing itself when it has none), with the standard Routing Line-Copy Lines.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure CreateVersion(var EcoLine: Record "MFG ECO Line")
    var
        RoutingHeader: Record "Routing Header";
        RoutingVersion: Record "Routing Version";
        RoutingLineCopyLines: Codeunit "Routing Line-Copy Lines";
        VersionManagement: Codeunit VersionManagement;
        FromVersionCode: Code[20];
    begin
        if EcoLine."New Version Code" <> '' then
            exit;

        RoutingHeader.Get(EcoLine."No.");
        FromVersionCode := VersionManagement.GetRtngVersion(RoutingHeader."No.", WorkDate(), true);

        RoutingVersion.Init();
        RoutingVersion."Routing No." := RoutingHeader."No.";
        RoutingVersion."Version Code" := EcoLine."ECO No.";
        RoutingVersion.Description := RoutingHeader.Description;
        RoutingVersion.Type := RoutingHeader.Type;
        RoutingVersion.Status := RoutingVersion.Status::"Under Development";
        RoutingVersion.Insert(true);

        RoutingLineCopyLines.CopyRouting(RoutingHeader."No.", FromVersionCode, RoutingHeader, RoutingVersion."Version Code");

        EcoLine."New Version Code" := RoutingVersion."Version Code";
        EcoLine.Modify(true);
    end;

    /// <summary>
    /// Sets the version's starting date to the effective date and certifies it, which runs the standard routing
    /// check.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    /// <param name="EffectiveDate">The date the version takes effect.</param>
    procedure Certify(EcoLine: Record "MFG ECO Line"; EffectiveDate: Date)
    var
        RoutingVersion: Record "Routing Version";
    begin
        RoutingVersion.Get(EcoLine."No.", EcoLine."New Version Code");
        RoutingVersion.Validate("Starting Date", EffectiveDate);
        RoutingVersion.Modify(true);
        RoutingVersion.Validate(Status, RoutingVersion.Status::Certified);
    end;

    /// <summary>
    /// Adds every planned, firm planned and released production order line that uses the routing.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    /// <param name="TempImpact">The impact buffer.</param>
    procedure CollectImpact(EcoLine: Record "MFG ECO Line"; var TempImpact: Record "MFG ECO Impact" temporary)
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetLoadFields(Status, "Prod. Order No.", "Line No.", "Item No.", Quantity, "Due Date", "Routing Version Code");
        ProdOrderLine.SetFilter(Status, '%1|%2|%3', ProdOrderLine.Status::Planned, ProdOrderLine.Status::"Firm Planned", ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Routing No.", EcoLine."No.");
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
            TempImpact."Version In Use" := ProdOrderLine."Routing Version Code";
            TempImpact.Insert();
        until ProdOrderLine.Next() = 0;
    end;

    /// <summary>
    /// Opens the new version of the routing.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure OpenVersion(EcoLine: Record "MFG ECO Line")
    var
        RoutingVersion: Record "Routing Version";
    begin
        if not RoutingVersion.Get(EcoLine."No.", EcoLine."New Version Code") then
            exit;
        Page.Run(Page::"Routing Version", RoutingVersion);
    end;
}
