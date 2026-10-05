namespace ManufacturingAdvanced.EngineeringChange;

using System.Automation;

codeunit 85810 "MFG ECO Workflow Mgt."
{
    Access = Public;

    var
        SendEventCodeTok: Label 'MFGRUNWORKFLOWONSENDECOFORAPPROVAL', Locked = true;
        CancelEventCodeTok: Label 'MFGRUNWORKFLOWONCANCELECOAPPROVALREQUEST', Locked = true;
        SendEventDescTxt: Label 'Approval of an engineering change is requested.';
        CancelEventDescTxt: Label 'An approval request for an engineering change is canceled.';
        TemplateCodeTok: Label 'MFGECOAPW', Locked = true;
        TemplateDescTxt: Label 'Engineering change approval workflow';
        CategoryCodeTok: Label 'MFG', Locked = true;
        CategoryDescTxt: Label 'Manufacturing';
        ConditionTok: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="MFG ECO Header">%1</DataItem></DataItems></ReportParameters>', Locked = true;

    /// <summary>
    /// The workflow event raised when an engineering change is sent for approval.
    /// </summary>
    /// <returns>The event function name.</returns>
    procedure SendForApprovalEventCode(): Code[128]
    begin
        exit(SendEventCodeTok);
    end;

    /// <summary>
    /// The workflow event raised when the approval request of an engineering change is canceled.
    /// </summary>
    /// <returns>The event function name.</returns>
    procedure CancelApprovalEventCode(): Code[128]
    begin
        exit(CancelEventCodeTok);
    end;

    /// <summary>
    /// The description of the workflow template, as users see it on the Workflow Templates page.
    /// </summary>
    /// <returns>The description.</returns>
    procedure TemplateDescription(): Text
    begin
        exit(TemplateDescTxt);
    end;

    /// <summary>
    /// The code of the workflow template, without the template token.
    /// </summary>
    /// <returns>The code.</returns>
    procedure TemplateCode(): Code[17]
    begin
        exit(TemplateCodeTok);
    end;

    /// <summary>
    /// Adds the two engineering change events to the workflow event library, relates approval entries to the change
    /// (a workflow mixing both cannot be enabled without it), and declares which standard events and responses may
    /// follow them, so they can be combined in the workflow designer. Idempotent.
    /// </summary>
    procedure AddEventsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertTableRelation(Database::"MFG ECO Header", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));

        WorkflowEventHandling.AddEventToLibrary(SendEventCodeTok, Database::"MFG ECO Header", SendEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(CancelEventCodeTok, Database::"MFG ECO Header", CancelEventDescTxt, 0, false);

        WorkflowEventHandling.AddEventPredecessor(CancelEventCodeTok, SendEventCodeTok);
        WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(), SendEventCodeTok);
        WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(), SendEventCodeTok);
        WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(), SendEventCodeTok);

        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.RestrictRecordUsageCode(), SendEventCodeTok);
        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(), SendEventCodeTok);
        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode(), SendEventCodeTok);
        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(), SendEventCodeTok);
        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(), CancelEventCodeTok);
        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.AllowRecordUsageCode(), CancelEventCodeTok);
        WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode(), CancelEventCodeTok);
    end;

    /// <summary>
    /// Creates the engineering change approval workflow template, built from Business Central's standard document
    /// approval steps, unless it exists. Ensures the event and response libraries first.
    /// </summary>
    procedure EnsureTemplate()
    var
        Workflow: Record Workflow;
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        BlankDateFormula: DateFormula;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(TemplateCodeTok)) then begin
            if not Workflow.Template then
                WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
            exit;
        end;

        WorkflowResponseHandling.CreateResponsesLibrary();
        AddEventsToLibrary();
        WorkflowSetup.InsertWorkflowCategory(CategoryCodeTok, CategoryDescTxt);
        WorkflowSetup.InsertWorkflowTemplate(Workflow, TemplateCodeTok, TemplateDescTxt, CategoryCodeTok);

        WorkflowStepArgument."Approver Type" := WorkflowStepArgument."Approver Type"::Approver;
        WorkflowStepArgument."Approver Limit Type" := WorkflowStepArgument."Approver Limit Type"::"Direct Approver";
        WorkflowStepArgument."Due Date Formula" := BlankDateFormula;
        WorkflowStepArgument."Link Target Page" := Page::"MFG ECO Card";
        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            StatusCondition(Enum::"MFG ECO Status"::MFGOpen), SendEventCodeTok,
            StatusCondition(Enum::"MFG ECO Status"::MFGPendingApproval), CancelEventCodeTok,
            WorkflowStepArgument, true);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    /// <summary>
    /// Fills the approval entry of an engineering change with its number.
    /// </summary>
    /// <param name="RecRef">The record approved.</param>
    /// <param name="ApprovalEntryArgument">The approval entry being prepared.</param>
    procedure PopulateApprovalEntry(RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
        EcoHeader: Record "MFG ECO Header";
    begin
        if RecRef.Number <> Database::"MFG ECO Header" then
            exit;
        RecRef.SetTable(EcoHeader);
        ApprovalEntryArgument."Document No." := EcoHeader."No.";
    end;

    /// <summary>
    /// Response Set Status to Pending Approval, for an engineering change.
    /// </summary>
    /// <param name="RecRef">The record the response runs on.</param>
    /// <param name="Variant">Receives the updated change.</param>
    /// <param name="IsHandled">Set when the record is an engineering change.</param>
    procedure SetPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        if not GetEcoHeader(RecRef, EcoHeader) then
            exit;
        Engine.MarkPendingApproval(EcoHeader);
        Variant := EcoHeader;
        IsHandled := true;
    end;

    /// <summary>
    /// Response Release Document, for an engineering change: every approver approved it.
    /// </summary>
    /// <param name="RecRef">The record the response runs on.</param>
    /// <param name="Handled">Set when the record is an engineering change.</param>
    procedure Release(RecRef: RecordRef; var Handled: Boolean)
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        if not GetEcoHeader(RecRef, EcoHeader) then
            exit;
        Engine.MarkApproved(EcoHeader);
        Handled := true;
    end;

    /// <summary>
    /// Response Open Document, for an engineering change: the request was rejected or canceled.
    /// </summary>
    /// <param name="RecRef">The record the response runs on.</param>
    /// <param name="Handled">Set when the record is an engineering change.</param>
    procedure Open(RecRef: RecordRef; var Handled: Boolean)
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        if not GetEcoHeader(RecRef, EcoHeader) then
            exit;
        Engine.MarkOpen(EcoHeader);
        Handled := true;
    end;

    local procedure GetEcoHeader(RecRef: RecordRef; var EcoHeader: Record "MFG ECO Header"): Boolean
    begin
        if RecRef.Number <> Database::"MFG ECO Header" then
            exit(false);
        RecRef.SetTable(EcoHeader);
        exit(EcoHeader.Get(EcoHeader."No."));
    end;

    local procedure StatusCondition(Status: Enum "MFG ECO Status"): Text
    var
        EcoHeader: Record "MFG ECO Header";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        EcoHeader.SetRange(Status, Status);
        exit(StrSubstNo(ConditionTok, WorkflowSetup.Encode(EcoHeader.GetView(false))));
    end;
}
