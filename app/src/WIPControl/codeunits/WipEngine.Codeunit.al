namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

codeunit 85202 "MFG WIP Engine"
{
    Access = Public;

    var
        NotesSeparatorTok: Label ' | ', Locked = true;
        BlockedErr: Label 'Production order %1 cannot be finished from WIP control: %2', Comment = '%1 = the production order number, %2 = what the checks found';
        NotCandidateErr: Label 'Production order %1 is not ready to be finished: it is not released, or some of its output is still missing.', Comment = '%1 = the production order number';

    /// <summary>
    /// Rebuilds the finish proposals: every released production order whose output is complete and whose
    /// last output is at least the configured number of days old gets a proposal, valued and checked.
    /// </summary>
    /// <returns>The number of proposals.</returns>
    procedure Suggest(): Integer
    var
        Proposal: Record "MFG Finish Proposal";
        ProductionOrder: Record "Production Order";
    begin
        Proposal.DeleteAll();

        ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
        if ProductionOrder.FindSet() then
            repeat
                EvaluateOrder(ProductionOrder);
            until ProductionOrder.Next() = 0;

        exit(Proposal.Count());
    end;

    /// <summary>
    /// Creates or refreshes the finish proposal of one production order, or removes it when the order no
    /// longer qualifies.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    /// <returns>True when the order qualifies and has a proposal.</returns>
    procedure EvaluateOrder(ProductionOrder: Record "Production Order"): Boolean
    var
        Proposal: Record "MFG Finish Proposal";
        Setup: Record "MFG WIP Setup";
        Locator: Codeunit "MFG WIP Locator";
        Exists: Boolean;
    begin
        Exists := Proposal.Get(ProductionOrder."No.");
        if not IsOutputComplete(ProductionOrder) then begin
            if Exists then
                Proposal.Delete();
            exit(false);
        end;

        if not Exists then begin
            Proposal.Init();
            Proposal."Prod. Order No." := ProductionOrder."No.";
        end;
        Proposal.Description := ProductionOrder.Description;
        Proposal."Source No." := ProductionOrder."Source No.";
        FillQuantities(ProductionOrder, Proposal);
        Locator.Valuation().Calculate(ProductionOrder, Proposal);

        if Proposal."Last Output Date" <> 0D then
            Proposal."Days Since Output" := WorkDate() - Proposal."Last Output Date";
        if not Setup.Get() then
            Clear(Setup);
        if (Proposal."Last Output Date" = 0D) or (Proposal."Days Since Output" < Setup."Min. Days Since Output") then begin
            if Exists then
                Proposal.Delete();
            exit(false);
        end;

        RunChecks(ProductionOrder, Proposal);
        Proposal."Suggested At" := CurrentDateTime();
        if Exists then
            Proposal.Modify(true)
        else
            Proposal.Insert(true);
        exit(true);
    end;

    /// <summary>
    /// Finishes every selected proposal with status Ready, one order at a time, through the standard status
    /// change. An order that fails keeps its proposal with status Failed and the error in its notes; the
    /// others go ahead. Commits before each order, so that one failure does not undo the orders before it.
    /// </summary>
    /// <returns>The number of orders finished.</returns>
    procedure FinishSelected(): Integer
    var
        Proposal: Record "MFG Finish Proposal";
        ProductionOrder: Record "Production Order";
        Finished: Integer;
    begin
        Proposal.SetRange(Selected, true);
        Proposal.SetRange(Status, Proposal.Status::MFGReady);
        if not Proposal.FindSet() then
            exit(0);

        repeat
            Commit();
            if ProductionOrder.Get(ProductionOrder.Status::Released, Proposal."Prod. Order No.") then
                if Codeunit.Run(Codeunit::"MFG WIP Finish Order", ProductionOrder) then begin
                    MarkFinished(Proposal);
                    Finished += 1;
                end else
                    MarkFailed(Proposal, GetLastErrorText());
        until Proposal.Next() = 0;
        exit(Finished);
    end;

    /// <summary>
    /// Re-evaluates one released production order and finishes it through the standard status change.
    /// Errors when the order does not qualify or a blocking check finds something.
    /// </summary>
    /// <param name="ProductionOrder">The released production order.</param>
    procedure FinishOrder(var ProductionOrder: Record "Production Order")
    var
        Proposal: Record "MFG Finish Proposal";
    begin
        if not EvaluateOrder(ProductionOrder) then
            Error(NotCandidateErr, ProductionOrder."No.");

        Proposal.Get(ProductionOrder."No.");
        if Proposal.Status = Proposal.Status::MFGBlocked then
            Error(BlockedErr, ProductionOrder."No.", Proposal.Notes);

        Codeunit.Run(Codeunit::"MFG WIP Finish Order", ProductionOrder);
        MarkFinished(Proposal);
    end;

    /// <summary>
    /// Determines whether a released production order has lines and none of them still has quantity to
    /// output.
    /// </summary>
    /// <param name="ProductionOrder">The production order.</param>
    /// <returns>True when the order is released and its output is complete.</returns>
    procedure IsOutputComplete(ProductionOrder: Record "Production Order"): Boolean
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if ProductionOrder.Status <> ProductionOrder.Status::Released then
            exit(false);

        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.IsEmpty() then
            exit(false);

        ProdOrderLine.SetFilter("Remaining Quantity", '>0');
        exit(ProdOrderLine.IsEmpty());
    end;

    /// <summary>
    /// Creates a configuration row, with the check's own default severity and description, for every
    /// check that does not have one yet. Rows that exist keep the severity the user chose.
    /// </summary>
    procedure EnsureChecks()
    var
        FinishCheckRow: Record "MFG Finish Check";
        FinishCheck: Interface "MFG IFinishCheck";
        Check: Enum "MFG Finish Check Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Finish Check Type".Ordinals() do begin
            Check := Enum::"MFG Finish Check Type".FromInteger(Ordinal);
            if (Check <> Check::MFGNone) and not FinishCheckRow.Get(Check) then begin
                FinishCheck := Check;
                FinishCheckRow.Init();
                FinishCheckRow.Check := Check;
                FinishCheckRow.Severity := FinishCheck.DefaultSeverity();
                FinishCheckRow.Description := CopyStr(FinishCheck.Description(), 1, MaxStrLen(FinishCheckRow.Description));
                FinishCheckRow.Insert(true);
            end;
        end;
    end;

    local procedure FillQuantities(ProductionOrder: Record "Production Order"; var Proposal: Record "MFG Finish Proposal")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.CalcSums(Quantity, "Finished Quantity");
        Proposal.Quantity := ProdOrderLine.Quantity;
        Proposal."Finished Quantity" := ProdOrderLine."Finished Quantity";
    end;

    local procedure RunChecks(ProductionOrder: Record "Production Order"; var Proposal: Record "MFG Finish Proposal")
    var
        FinishCheck: Interface "MFG IFinishCheck";
        Check: Enum "MFG Finish Check Type";
        Severity: Enum "MFG Finish Check Severity";
        Notes: TextBuilder;
        Reason: Text;
        Ordinal: Integer;
    begin
        Proposal.Status := Proposal.Status::MFGReady;
        foreach Ordinal in Enum::"MFG Finish Check Type".Ordinals() do begin
            Check := Enum::"MFG Finish Check Type".FromInteger(Ordinal);
            Severity := GetSeverity(Check);
            if Severity <> Severity::MFGOff then begin
                FinishCheck := Check;
                Reason := '';
                if FinishCheck.Evaluate(ProductionOrder, Reason) then begin
                    if Notes.Length() > 0 then
                        Notes.Append(NotesSeparatorTok);
                    Notes.Append(Reason);
                    if Severity = Severity::MFGBlock then
                        Proposal.Status := Proposal.Status::MFGBlocked;
                end;
            end;
        end;

        Proposal.Notes := CopyStr(Notes.ToText(), 1, MaxStrLen(Proposal.Notes));
        if Proposal.Status = Proposal.Status::MFGBlocked then
            Proposal.Selected := false;
    end;

    local procedure GetSeverity(Check: Enum "MFG Finish Check Type"): Enum "MFG Finish Check Severity"
    var
        FinishCheckRow: Record "MFG Finish Check";
        FinishCheck: Interface "MFG IFinishCheck";
    begin
        if Check = Check::MFGNone then
            exit(Enum::"MFG Finish Check Severity"::MFGOff);

        FinishCheckRow.SetLoadFields(Severity);
        if FinishCheckRow.Get(Check) then
            exit(FinishCheckRow.Severity);

        FinishCheck := Check;
        exit(FinishCheck.DefaultSeverity());
    end;

    local procedure MarkFinished(var Proposal: Record "MFG Finish Proposal")
    begin
        Proposal.Status := Proposal.Status::MFGFinished;
        Proposal.Selected := false;
        Proposal.Modify(true);
    end;

    local procedure MarkFailed(var Proposal: Record "MFG Finish Proposal"; ErrorText: Text)
    begin
        Proposal.Status := Proposal.Status::MFGFailed;
        Proposal.Selected := false;
        Proposal.Notes := CopyStr(ErrorText, 1, MaxStrLen(Proposal.Notes));
        Proposal.Modify(true);
    end;
}
