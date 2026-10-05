namespace ManufacturingAdvanced.EngineeringChange;

using System.Automation;

codeunit 85811 "MFG ECO Workflow Events"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventsToLibrary, '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        WorkflowMgt.AddEventsToLibrary();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnAfterInitWorkflowTemplates, '', false, false)]
    local procedure OnAfterInitWorkflowTemplates()
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        WorkflowMgt.EnsureTemplate();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnPopulateApprovalEntryArgument, '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        WorkflowMgt.PopulateApprovalEntry(RecRef, ApprovalEntryArgument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSetStatusToPendingApproval, '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        WorkflowMgt.SetPendingApproval(RecRef, Variant, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnReleaseDocument, '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        WorkflowMgt.Release(RecRef, Handled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnOpenDocument, '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        WorkflowMgt.Open(RecRef, Handled);
    end;
}
