namespace ManufacturingAdvanced.CostDrift;

using ManufacturingAdvanced.Core;
using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.StandardCost;

codeunit 85302 "MFG Cost Drift Engine"
{
    Access = Public;

    var
        DefaultWorksheetTok: Label 'MFG-DRIFT', Locked = true;
        DefaultWorksheetLbl: Label 'Standard cost drift';

    /// <summary>
    /// Rebuilds the drift lines: every active source proposes a standard cost for the items it can price, and
    /// every item whose proposal differs from its current standard cost by at least the tolerance is listed.
    /// When two sources price the same item, the first source in the enum wins.
    /// </summary>
    /// <returns>The number of drift lines.</returns>
    procedure Calculate(): Integer
    var
        DriftLine: Record "MFG Cost Drift Line";
        TempDriftLine: Record "MFG Cost Drift Line" temporary;
        Setup: Record "MFG Cost Drift Setup";
        DriftSourceRow: Record "MFG Drift Source";
        DriftSource: Interface "MFG IDriftSource";
        Source: Enum "MFG Drift Source Type";
        CalculatedAt: DateTime;
        Ordinal: Integer;
    begin
        EnsureSources();
        if not Setup.Get() then
            Clear(Setup);

        foreach Ordinal in Enum::"MFG Drift Source Type".Ordinals() do begin
            Source := Enum::"MFG Drift Source Type".FromInteger(Ordinal);
            if DriftSourceRow.Get(Source) then
                if DriftSourceRow.Active then begin
                    DriftSource := Source;
                    DriftSource.Collect(TempDriftLine);
                end;
        end;

        DriftLine.DeleteAll();
        CalculatedAt := CurrentDateTime();
        TempDriftLine.Reset();
        if TempDriftLine.FindSet() then
            repeat
                ApplyDrift(TempDriftLine);
                if IsBeyondTolerance(TempDriftLine, Setup."Tolerance %") then begin
                    DriftLine := TempDriftLine;
                    DriftLine."Calculated At" := CalculatedAt;
                    DriftLine.Insert(true);
                end;
            until TempDriftLine.Next() = 0;

        exit(DriftLine.Count());
    end;

    /// <summary>
    /// Sends every selected drift line that has not been sent yet to the standard cost worksheet named in the
    /// setup, through the source that proposed it.
    /// </summary>
    /// <returns>The number of lines sent.</returns>
    procedure TransferSelected(): Integer
    var
        DriftLine: Record "MFG Cost Drift Line";
        Sent: Integer;
    begin
        DriftLine.SetRange(Selected, true);
        DriftLine.SetRange(Transferred, false);
        if not DriftLine.FindSet() then
            exit(0);

        repeat
            TransferLine(DriftLine);
            Sent += 1;
        until DriftLine.Next() = 0;
        exit(Sent);
    end;

    /// <summary>
    /// Sends one drift line to the standard cost worksheet named in the setup, creating the worksheet when it
    /// does not exist, and marks the line as sent. Nothing changes on the item until the worksheet is implemented.
    /// </summary>
    /// <param name="DriftLine">The drift line.</param>
    procedure TransferLine(var DriftLine: Record "MFG Cost Drift Line")
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        DriftSource: Interface "MFG IDriftSource";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGCostDrift);

        DriftSource := DriftLine.Source;
        DriftSource.TransferToWorksheet(DriftLine, EnsureWorksheet());

        DriftLine.Transferred := true;
        DriftLine.Selected := false;
        DriftLine.Modify(true);
    end;

    /// <summary>
    /// Rebuilds the order variances: one line per production order finished within the variance period, with
    /// its output cost and its variances by type, from the value entries posted by cost adjustment.
    /// </summary>
    /// <returns>The number of orders listed.</returns>
    procedure CalculateVariances(): Integer
    var
        OrderVariance: Record "MFG Order Variance";
        ProductionOrder: Record "Production Order";
        Setup: Record "MFG Cost Drift Setup";
        Days: Integer;
    begin
        if not Setup.Get() then
            Clear(Setup);
        Days := Setup."Variance Days";
        if Days <= 0 then
            Days := 30;

        OrderVariance.DeleteAll();
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Finished);
        ProductionOrder.SetRange("Finished Date", WorkDate() - Days, WorkDate());
        if ProductionOrder.FindSet() then
            repeat
                InsertVariance(ProductionOrder);
            until ProductionOrder.Next() = 0;
        exit(OrderVariance.Count());
    end;

    /// <summary>
    /// Creates a configuration row, with the source's description and active, for every source that does not
    /// have one yet. Rows that exist keep the choice the user made.
    /// </summary>
    procedure EnsureSources()
    var
        DriftSourceRow: Record "MFG Drift Source";
        DriftSource: Interface "MFG IDriftSource";
        Source: Enum "MFG Drift Source Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Drift Source Type".Ordinals() do begin
            Source := Enum::"MFG Drift Source Type".FromInteger(Ordinal);
            if (Source <> Source::MFGNone) and not DriftSourceRow.Get(Source) then begin
                DriftSource := Source;
                DriftSourceRow.Init();
                DriftSourceRow.Source := Source;
                DriftSourceRow.Active := true;
                DriftSourceRow.Description := CopyStr(DriftSource.Description(), 1, MaxStrLen(DriftSourceRow.Description));
                DriftSourceRow.Insert(true);
            end;
        end;
    end;

    /// <summary>
    /// Returns the standard cost worksheet named in the setup, creating it, and naming the default one in the
    /// setup, when needed.
    /// </summary>
    /// <returns>The worksheet name.</returns>
    procedure EnsureWorksheet(): Code[10]
    var
        Setup: Record "MFG Cost Drift Setup";
        StandardCostWorksheetName: Record "Standard Cost Worksheet Name";
        FeatureSetup: Codeunit "MFG Cost Drift Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        if Setup."Worksheet Name" = '' then begin
            Setup."Worksheet Name" := DefaultWorksheetTok;
            Setup.Modify(true);
        end;

        if not StandardCostWorksheetName.Get(Setup."Worksheet Name") then begin
            StandardCostWorksheetName.Init();
            StandardCostWorksheetName.Name := Setup."Worksheet Name";
            StandardCostWorksheetName.Description := DefaultWorksheetLbl;
            StandardCostWorksheetName.Insert(true);
        end;
        exit(Setup."Worksheet Name");
    end;

    local procedure ApplyDrift(var TempDriftLine: Record "MFG Cost Drift Line" temporary)
    begin
        TempDriftLine."Drift Amount" := TempDriftLine."Proposed Standard Cost" - TempDriftLine."Current Standard Cost";
        if TempDriftLine."Current Standard Cost" <> 0 then
            TempDriftLine."Drift %" := Round(TempDriftLine."Drift Amount" / TempDriftLine."Current Standard Cost" * 100, 0.01)
        else
            if TempDriftLine."Drift Amount" <> 0 then
                TempDriftLine."Drift %" := 100
            else
                TempDriftLine."Drift %" := 0;
    end;

    local procedure IsBeyondTolerance(TempDriftLine: Record "MFG Cost Drift Line" temporary; TolerancePct: Decimal): Boolean
    begin
        if TempDriftLine."Drift Amount" = 0 then
            exit(false);
        exit(Abs(TempDriftLine."Drift %") >= TolerancePct);
    end;

    local procedure InsertVariance(ProductionOrder: Record "Production Order")
    var
        OrderVariance: Record "MFG Order Variance";
        ValueEntry: Record "Value Entry";
    begin
        OrderVariance.Init();
        OrderVariance."Prod. Order No." := ProductionOrder."No.";
        OrderVariance."Item No." := ProductionOrder."Source No.";
        OrderVariance.Description := ProductionOrder.Description;
        OrderVariance."Finished Date" := ProductionOrder."Finished Date";

        ValueEntry.SetRange("Order Type", "Inventory Order Type"::Production);
        ValueEntry.SetRange("Order No.", ProductionOrder."No.");
        ValueEntry.SetRange("Item Ledger Entry Type", "Item Ledger Entry Type"::Output);
        ValueEntry.SetFilter("Entry Type", '<>%1', "Cost Entry Type"::Variance);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        OrderVariance."Output Cost" := ValueEntry."Cost Amount (Actual)";

        ValueEntry.SetRange("Item Ledger Entry Type");
        ValueEntry.SetRange("Entry Type", "Cost Entry Type"::Variance);
        OrderVariance."Material Variance" := SumVariance(ValueEntry, "Cost Variance Type"::Material);
        OrderVariance."Capacity Variance" := SumVariance(ValueEntry, "Cost Variance Type"::Capacity);
        OrderVariance."Cap. Overhead Variance" := SumVariance(ValueEntry, "Cost Variance Type"::"Capacity Overhead");
        OrderVariance."Mfg. Overhead Variance" := SumVariance(ValueEntry, "Cost Variance Type"::"Manufacturing Overhead");
        OrderVariance."Subcontracted Variance" := SumVariance(ValueEntry, "Cost Variance Type"::Subcontracted);
        OrderVariance."Total Variance" :=
            OrderVariance."Material Variance" + OrderVariance."Capacity Variance" + OrderVariance."Cap. Overhead Variance" +
            OrderVariance."Mfg. Overhead Variance" + OrderVariance."Subcontracted Variance";
        if OrderVariance."Output Cost" <> 0 then
            OrderVariance."Variance %" := Round(OrderVariance."Total Variance" / OrderVariance."Output Cost" * 100, 0.01);
        OrderVariance.Insert(true);
    end;

    local procedure SumVariance(var ValueEntry: Record "Value Entry"; VarianceType: Enum "Cost Variance Type"): Decimal
    begin
        ValueEntry.SetRange("Variance Type", VarianceType);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        exit(ValueEntry."Cost Amount (Actual)");
    end;
}
