namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

codeunit 85102 "MFG Preflight Engine"
{
    Access = Public;

    var
        NoFindingsMsg: Label 'Production order %1 passed every pre-flight check.', Comment = '%1 = the production order number';

    /// <summary>
    /// Runs every check that is not switched off against a production order and returns the findings.
    /// Writes nothing.
    /// </summary>
    /// <param name="ProductionOrder">The order to check.</param>
    /// <param name="TempFinding">Receives the findings; existing contents are discarded.</param>
    procedure RunChecks(ProductionOrder: Record "Production Order"; var TempFinding: Record "MFG Preflight Finding" temporary)
    var
        Collector: Codeunit "MFG Preflight Collector";
        PreflightCheck: Interface "MFG IPreflightCheck";
        Check: Enum "MFG Preflight Check Type";
        Severity: Enum "MFG Preflight Severity";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Preflight Check Type".Ordinals() do begin
            Check := Enum::"MFG Preflight Check Type".FromInteger(Ordinal);
            Severity := GetSeverity(Check);
            if Severity <> Severity::MFGOff then begin
                PreflightCheck := Check;
                Collector.SetContext(ProductionOrder, Check, Severity);
                PreflightCheck.Run(ProductionOrder, Collector);
            end;
        end;

        Collector.GetFindings(TempFinding);
    end;

    /// <summary>
    /// Replaces the stored findings of a production order with the given ones, stamped with the time and
    /// the current user.
    /// </summary>
    /// <param name="ProductionOrder">The order the findings belong to.</param>
    /// <param name="TempFinding">The findings to store.</param>
    procedure StoreFindings(ProductionOrder: Record "Production Order"; var TempFinding: Record "MFG Preflight Finding" temporary)
    var
        Finding: Record "MFG Preflight Finding";
        CheckedAt: DateTime;
    begin
        Finding.SetRange("Prod. Order Status", ProductionOrder.Status);
        Finding.SetRange("Prod. Order No.", ProductionOrder."No.");
        Finding.DeleteAll();

        TempFinding.Reset();
        if not TempFinding.FindSet() then
            exit;

        CheckedAt := CurrentDateTime();
        repeat
            Finding := TempFinding;
            Finding."Entry No." := 0;
            Finding."Checked At" := CheckedAt;
            Finding."Checked By" := CopyStr(UserId(), 1, MaxStrLen(Finding."Checked By"));
            Finding.Insert(true);
        until TempFinding.Next() = 0;
    end;

    /// <summary>
    /// Runs the checks against a production order and stores the findings.
    /// </summary>
    /// <param name="ProductionOrder">The order to check.</param>
    /// <param name="TempFinding">Receives the findings.</param>
    procedure RunAndStore(ProductionOrder: Record "Production Order"; var TempFinding: Record "MFG Preflight Finding" temporary)
    begin
        RunChecks(ProductionOrder, TempFinding);
        StoreFindings(ProductionOrder, TempFinding);
    end;

    /// <summary>
    /// Runs and stores the checks for a production order chosen on a page, then shows the findings, or a
    /// message when there are none.
    /// </summary>
    /// <param name="ProductionOrder">The order to check.</param>
    procedure RunInteractive(ProductionOrder: Record "Production Order")
    var
        Finding: Record "MFG Preflight Finding";
        TempFinding: Record "MFG Preflight Finding" temporary;
    begin
        RunAndStore(ProductionOrder, TempFinding);
        if TempFinding.IsEmpty() then begin
            Message(NoFindingsMsg, ProductionOrder."No.");
            exit;
        end;

        Finding.SetRange("Prod. Order Status", ProductionOrder.Status);
        Finding.SetRange("Prod. Order No.", ProductionOrder."No.");
        Page.Run(Page::"MFG Preflight Findings", Finding);
    end;

    /// <summary>
    /// Counts the findings of one severity.
    /// </summary>
    /// <param name="TempFinding">The findings to count.</param>
    /// <param name="Severity">The severity to count.</param>
    /// <returns>The number of findings with that severity.</returns>
    procedure CountFindings(var TempFinding: Record "MFG Preflight Finding" temporary; Severity: Enum "MFG Preflight Severity"): Integer
    begin
        TempFinding.Reset();
        TempFinding.SetRange(Severity, Severity);
        exit(TempFinding.Count());
    end;

    /// <summary>
    /// Creates a configuration row, with the check's own default severity and description, for every
    /// check that does not have one yet. Rows that exist keep the severity the user chose.
    /// </summary>
    procedure EnsureChecks()
    var
        PreflightCheckRow: Record "MFG Preflight Check";
        PreflightCheck: Interface "MFG IPreflightCheck";
        Check: Enum "MFG Preflight Check Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"MFG Preflight Check Type".Ordinals() do begin
            Check := Enum::"MFG Preflight Check Type".FromInteger(Ordinal);
            if (Check <> Check::MFGNone) and not PreflightCheckRow.Get(Check) then begin
                PreflightCheck := Check;
                PreflightCheckRow.Init();
                PreflightCheckRow.Check := Check;
                PreflightCheckRow.Severity := PreflightCheck.DefaultSeverity();
                PreflightCheckRow.Description := CopyStr(PreflightCheck.Description(), 1, MaxStrLen(PreflightCheckRow.Description));
                PreflightCheckRow.Insert(true);
            end;
        end;
    end;

    local procedure GetSeverity(Check: Enum "MFG Preflight Check Type"): Enum "MFG Preflight Severity"
    var
        PreflightCheckRow: Record "MFG Preflight Check";
        PreflightCheck: Interface "MFG IPreflightCheck";
    begin
        if Check = Check::MFGNone then
            exit(Enum::"MFG Preflight Severity"::MFGOff);

        PreflightCheckRow.SetLoadFields(Severity);
        if PreflightCheckRow.Get(Check) then
            exit(PreflightCheckRow.Severity);

        PreflightCheck := Check;
        exit(PreflightCheck.DefaultSeverity());
    end;
}
