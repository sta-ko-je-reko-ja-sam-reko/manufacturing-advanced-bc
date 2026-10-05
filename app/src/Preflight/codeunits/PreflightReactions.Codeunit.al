namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

codeunit 85103 "MFG Preflight Reactions" implements "MFG IPreflightReactions"
{
    Access = Public;

    var
        ReleaseBlockedErr: Label 'Production order %1 cannot be released: the pre-flight checks found %2 error(s).%3%3%4%3Choose Run pre-flight on the order to see every finding.', Comment = '%1 = the production order number, %2 = the number of errors, %3 = a line break, %4 = the first findings, one per line';
        ConfirmWarningsQst: Label 'The pre-flight checks found %1 warning(s) on production order %2.%3%3%4%3Do you want to release it anyway?', Comment = '%1 = the number of warnings, %2 = the production order number, %3 = a line break, %4 = the first findings, one per line';

    /// <summary>
    /// Runs the pre-flight checks when a production order is about to be released, stores the findings,
    /// and refuses the release or asks for confirmation as the setup says. Does nothing while the feature
    /// is off, when the order is changing to any other status, or when checking on release is switched off.
    /// </summary>
    /// <param name="ProductionOrder">The order about to change status.</param>
    /// <param name="NewStatus">The status it is changing to.</param>
    procedure OnBeforeChangeStatus(var ProductionOrder: Record "Production Order"; NewStatus: Enum "Production Order Status")
    var
        Setup: Record "MFG Preflight Setup";
        TempFinding: Record "MFG Preflight Finding" temporary;
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Preflight Engine";
        Errors: Integer;
        Warnings: Integer;
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGPreflight) then
            exit;
        if NewStatus <> NewStatus::Released then
            exit;
        if not Setup.Get() then
            exit;
        if not Setup."Check on Release" then
            exit;

        Engine.RunAndStore(ProductionOrder, TempFinding);
        Errors := Engine.CountFindings(TempFinding, Enum::"MFG Preflight Severity"::MFGError);
        Warnings := Engine.CountFindings(TempFinding, Enum::"MFG Preflight Severity"::MFGWarning);

        if (Errors > 0) and Setup."Block on Errors" then
            Error(ReleaseBlockedErr, ProductionOrder."No.", Errors, NewLine(), ListFindings(TempFinding, Enum::"MFG Preflight Severity"::MFGError));

        if not Setup."Block on Errors" then
            Warnings += Errors;

        if (Warnings > 0) and Setup."Confirm Warnings" and GuiAllowed() then
            if not Confirm(ConfirmWarningsQst, false, Warnings, ProductionOrder."No.", NewLine(), ListFindings(TempFinding, Enum::"MFG Preflight Severity"::MFGOff)) then
                Error('');
    end;

    local procedure ListFindings(var TempFinding: Record "MFG Preflight Finding" temporary; OnlySeverity: Enum "MFG Preflight Severity"): Text
    var
        Lines: TextBuilder;
        Listed: Integer;
    begin
        TempFinding.Reset();
        if OnlySeverity <> OnlySeverity::MFGOff then
            TempFinding.SetRange(Severity, OnlySeverity);
        if not TempFinding.FindSet() then
            exit('');

        repeat
            Lines.AppendLine('- ' + TempFinding.Message);
            Listed += 1;
        until (TempFinding.Next() = 0) or (Listed >= MaxListedFindings());
        exit(Lines.ToText());
    end;

    local procedure MaxListedFindings(): Integer
    begin
        exit(5);
    end;

    local procedure NewLine(): Text
    var
        LineBreak: Text[2];
    begin
        LineBreak[1] := 13;
        LineBreak[2] := 10;
        exit(LineBreak);
    end;
}
