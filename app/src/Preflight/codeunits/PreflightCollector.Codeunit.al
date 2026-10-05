namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

codeunit 85108 "MFG Preflight Collector"
{
    Access = Public;

    var
        TempFinding: Record "MFG Preflight Finding" temporary;
        ProdOrderStatus: Enum "Production Order Status";
        ProdOrderNo: Code[20];
        CurrentCheck: Enum "MFG Preflight Check Type";
        CurrentSeverity: Enum "MFG Preflight Severity";

    /// <summary>
    /// Sets the order, the check and the severity the next findings belong to. The engine calls this
    /// before it runs each check, so a check only has to say what it found.
    /// </summary>
    /// <param name="ProductionOrder">The order being checked.</param>
    /// <param name="Check">The check about to run.</param>
    /// <param name="Severity">The severity its findings carry.</param>
    procedure SetContext(ProductionOrder: Record "Production Order"; Check: Enum "MFG Preflight Check Type"; Severity: Enum "MFG Preflight Severity")
    begin
        ProdOrderStatus := ProductionOrder.Status;
        ProdOrderNo := ProductionOrder."No.";
        CurrentCheck := Check;
        CurrentSeverity := Severity;
    end;

    /// <summary>
    /// Records one finding for the current order and check.
    /// </summary>
    /// <param name="ProdOrderLineNo">The production order line, or zero for the whole order.</param>
    /// <param name="ComponentLineNo">The component line, or zero when the finding is about the output.</param>
    /// <param name="ItemNo">The item concerned.</param>
    /// <param name="LocationCode">The location concerned.</param>
    /// <param name="MessageText">What is wrong and what to do about it.</param>
    procedure Add(ProdOrderLineNo: Integer; ComponentLineNo: Integer; ItemNo: Code[20]; LocationCode: Code[10]; MessageText: Text)
    begin
        TempFinding.Reset();
        if TempFinding.FindLast() then;

        TempFinding.Init();
        TempFinding."Entry No." += 1;
        TempFinding."Prod. Order Status" := ProdOrderStatus;
        TempFinding."Prod. Order No." := ProdOrderNo;
        TempFinding."Prod. Order Line No." := ProdOrderLineNo;
        TempFinding."Component Line No." := ComponentLineNo;
        TempFinding.Check := CurrentCheck;
        TempFinding.Severity := CurrentSeverity;
        TempFinding.Message := CopyStr(MessageText, 1, MaxStrLen(TempFinding.Message));
        TempFinding."Item No." := ItemNo;
        TempFinding."Location Code" := LocationCode;
        TempFinding.Insert();
    end;

    /// <summary>
    /// Copies every finding collected so far into the given buffer, replacing its contents.
    /// </summary>
    /// <param name="TempTarget">The buffer to fill.</param>
    procedure GetFindings(var TempTarget: Record "MFG Preflight Finding" temporary)
    begin
        TempTarget.Reset();
        TempTarget.DeleteAll();

        TempFinding.Reset();
        if not TempFinding.FindSet() then
            exit;

        repeat
            TempTarget := TempFinding;
            TempTarget.Insert();
        until TempFinding.Next() = 0;
    end;
}
