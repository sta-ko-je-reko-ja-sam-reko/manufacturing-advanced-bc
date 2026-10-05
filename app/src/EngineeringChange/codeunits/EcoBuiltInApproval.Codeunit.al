namespace ManufacturingAdvanced.EngineeringChange;

codeunit 85808 "MFG ECO Built-in Approval" implements "MFG IEcoApproval"
{
    Access = Public;

    var
        SelfApprovalErr: Label 'You requested engineering change %1, so someone else must approve it.', Comment = '%1 = the change number';

    /// <summary>
    /// Sets the change to pending approval; it is approved or rejected on the change card.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Submit(var EcoHeader: Record "MFG ECO Header")
    var
        Engine: Codeunit "MFG ECO Engine";
    begin
        Engine.MarkPendingApproval(EcoHeader);
    end;

    /// <summary>
    /// When the setup asks for a separate approver, the requester cannot decide on their own change.
    /// </summary>
    /// <param name="EcoHeader">The change pending approval.</param>
    procedure CheckDirectDecision(EcoHeader: Record "MFG ECO Header")
    var
        Setup: Record "MFG ECO Setup";
    begin
        Setup.SetLoadFields("Separate Approver");
        if Setup.Get() then
            if Setup."Separate Approver" and (EcoHeader."Requested By" = UserId()) then
                Error(SelfApprovalErr, EcoHeader."No.");
    end;

    /// <summary>
    /// Nothing to withdraw: the pending status is the whole request.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Cancel(var EcoHeader: Record "MFG ECO Header")
    begin
        EcoHeader.Get(EcoHeader."No.");
    end;
}
