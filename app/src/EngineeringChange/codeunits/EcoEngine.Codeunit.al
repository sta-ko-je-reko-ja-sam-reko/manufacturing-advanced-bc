namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;

codeunit 85802 "MFG ECO Engine"
{
    Access = Public;

    var
        WrongStatusErr: Label 'Engineering change %1 is %2. This step needs it to be %3.', Comment = '%1 = the change number, %2 = its status, %3 = the status needed';
        NoLinesErr: Label 'Engineering change %1 has no lines.', Comment = '%1 = the change number';
        NoVersionErr: Label 'Line %1 of engineering change %2 has no new version yet. Choose Create versions first.', Comment = '%1 = the line number, %2 = the change number';
        NoEffectiveDateErr: Label 'Enter the effective date of engineering change %1.', Comment = '%1 = the change number';
        SelfApprovalErr: Label 'You requested engineering change %1, so someone else must approve it.', Comment = '%1 = the change number';

    /// <summary>
    /// Creates, for every line that has none yet, the new BOM or routing version the change is made in.
    /// </summary>
    /// <param name="EcoHeader">The change, which must be open.</param>
    /// <returns>The number of lines with a new version.</returns>
    procedure CreateVersions(var EcoHeader: Record "MFG ECO Header"): Integer
    var
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGOpen);
        FindLines(EcoHeader, EcoLine);
        repeat
            EcoObject := EcoLine."Object Type";
            EcoObject.CreateVersion(EcoLine);
        until EcoLine.Next() = 0;
        exit(EcoLine.Count());
    end;

    /// <summary>
    /// Sends an open change for approval, once every line has its new version and the effective date is set.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure SubmitForApproval(var EcoHeader: Record "MFG ECO Header")
    var
        EcoLine: Record "MFG ECO Line";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGOpen);
        if EcoHeader."Effective Date" = 0D then
            Error(NoEffectiveDateErr, EcoHeader."No.");
        FindLines(EcoHeader, EcoLine);
        repeat
            if EcoLine."New Version Code" = '' then
                Error(NoVersionErr, EcoLine."Line No.", EcoHeader."No.");
        until EcoLine.Next() = 0;

        SetStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
    end;

    /// <summary>
    /// Approves a change pending approval. When the setup asks for a separate approver, the requester cannot
    /// approve their own change.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Approve(var EcoHeader: Record "MFG ECO Header")
    var
        Setup: Record "MFG ECO Setup";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
        Setup.SetLoadFields("Separate Approver");
        if Setup.Get() then
            if Setup."Separate Approver" and (EcoHeader."Requested By" = UserId()) then
                Error(SelfApprovalErr, EcoHeader."No.");

        EcoHeader."Approved By" := CopyStr(UserId(), 1, MaxStrLen(EcoHeader."Approved By"));
        EcoHeader."Approved At" := CurrentDateTime();
        SetStatus(EcoHeader, EcoHeader.Status::MFGApproved);
    end;

    /// <summary>
    /// Rejects a change pending approval.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Reject(var EcoHeader: Record "MFG ECO Header")
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
        EcoHeader."Approved By" := CopyStr(UserId(), 1, MaxStrLen(EcoHeader."Approved By"));
        EcoHeader."Approved At" := CurrentDateTime();
        SetStatus(EcoHeader, EcoHeader.Status::MFGRejected);
    end;

    /// <summary>
    /// Puts a pending or rejected change back to open, so it can be edited and submitted again.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Reopen(var EcoHeader: Record "MFG ECO Header")
    begin
        CheckEnabled();
        if not (EcoHeader.Status in [EcoHeader.Status::MFGPendingApproval, EcoHeader.Status::MFGRejected]) then
            CheckStatus(EcoHeader, EcoHeader.Status::MFGPendingApproval);
        EcoHeader."Approved By" := '';
        EcoHeader."Approved At" := 0DT;
        SetStatus(EcoHeader, EcoHeader.Status::MFGOpen);
    end;

    /// <summary>
    /// Implements an approved change: certifies every new version, starting on the effective date.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Implement(var EcoHeader: Record "MFG ECO Header")
    var
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
    begin
        CheckEnabled();
        CheckStatus(EcoHeader, EcoHeader.Status::MFGApproved);
        FindLines(EcoHeader, EcoLine);
        repeat
            EcoObject := EcoLine."Object Type";
            EcoObject.Certify(EcoLine, EcoHeader."Effective Date");
        until EcoLine.Next() = 0;

        EcoHeader.Get(EcoHeader."No.");
        EcoHeader."Implemented At" := CurrentDateTime();
        SetStatus(EcoHeader, EcoHeader.Status::MFGImplemented);
    end;

    /// <summary>
    /// Lists the open production order lines that use any BOM or routing the change touches.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    /// <param name="TempImpact">Receives the impact; existing contents are discarded.</param>
    procedure GetImpact(EcoHeader: Record "MFG ECO Header"; var TempImpact: Record "MFG ECO Impact" temporary)
    var
        EcoLine: Record "MFG ECO Line";
        EcoObject: Interface "MFG IEcoObject";
    begin
        TempImpact.Reset();
        TempImpact.DeleteAll();
        EcoLine.SetRange("ECO No.", EcoHeader."No.");
        if not EcoLine.FindSet() then
            exit;
        repeat
            EcoObject := EcoLine."Object Type";
            EcoObject.CollectImpact(EcoLine, TempImpact);
        until EcoLine.Next() = 0;
        TempImpact.Reset();
    end;

    local procedure FindLines(EcoHeader: Record "MFG ECO Header"; var EcoLine: Record "MFG ECO Line")
    begin
        EcoLine.SetRange("ECO No.", EcoHeader."No.");
        EcoLine.SetFilter("No.", '<>%1', '');
        if not EcoLine.FindSet() then
            Error(NoLinesErr, EcoHeader."No.");
    end;

    local procedure CheckStatus(EcoHeader: Record "MFG ECO Header"; Expected: Enum "MFG ECO Status")
    begin
        if EcoHeader.Status <> Expected then
            Error(WrongStatusErr, EcoHeader."No.", EcoHeader.Status, Expected);
    end;

    local procedure SetStatus(var EcoHeader: Record "MFG ECO Header"; NewStatus: Enum "MFG ECO Status")
    begin
        EcoHeader.Status := NewStatus;
        EcoHeader.Modify(true);
    end;

    local procedure CheckEnabled()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGEngineeringChange);
    end;
}
