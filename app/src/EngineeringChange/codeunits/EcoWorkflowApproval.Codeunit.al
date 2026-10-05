namespace ManufacturingAdvanced.EngineeringChange;

using System.Automation;

codeunit 85809 "MFG ECO Workflow Approval" implements "MFG IEcoApproval"
{
    Access = Public;

    var
        NoWorkflowErr: Label 'No enabled approval workflow exists for engineering changes. Create one on the Workflows page from the template %1, or set the approval method to On the change card.', Comment = '%1 = the workflow template description';
        UseApprovalEntriesErr: Label 'Engineering changes are approved through an approval workflow. Approve or reject engineering change %1 from Requests to Approve.', Comment = '%1 = the change number';

    /// <summary>
    /// Raises the workflow event for sending a change for approval. The enabled workflow then sets the change to
    /// pending approval and creates and sends the approval requests.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Submit(var EcoHeader: Record "MFG ECO Header")
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if not WorkflowManagement.CanExecuteWorkflow(EcoHeader, WorkflowMgt.SendForApprovalEventCode()) then
            Error(NoWorkflowErr, WorkflowMgt.TemplateDescription());
        WorkflowManagement.HandleEvent(WorkflowMgt.SendForApprovalEventCode(), EcoHeader);
        EcoHeader.Get(EcoHeader."No.");
    end;

    /// <summary>
    /// Under a workflow, approvers decide in Requests to Approve, never on the card.
    /// </summary>
    /// <param name="EcoHeader">The change pending approval.</param>
    procedure CheckDirectDecision(EcoHeader: Record "MFG ECO Header")
    begin
        Error(UseApprovalEntriesErr, EcoHeader."No.");
    end;

    /// <summary>
    /// Raises the workflow event for cancelling the approval request of a change pending approval, so the
    /// workflow cancels its approval entries.
    /// </summary>
    /// <param name="EcoHeader">The change.</param>
    procedure Cancel(var EcoHeader: Record "MFG ECO Header")
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if EcoHeader.Status = EcoHeader.Status::MFGPendingApproval then
            if WorkflowManagement.CanExecuteWorkflow(EcoHeader, WorkflowMgt.CancelApprovalEventCode()) then
                WorkflowManagement.HandleEvent(WorkflowMgt.CancelApprovalEventCode(), EcoHeader);
        EcoHeader.Get(EcoHeader."No.");
    end;
}
