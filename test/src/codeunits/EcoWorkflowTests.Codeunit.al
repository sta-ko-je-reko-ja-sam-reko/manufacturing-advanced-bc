namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.EngineeringChange;
using System.Automation;
using System.Security.User;
using System.TestLibraries.Utilities;

codeunit 89023 "MFG ECO Workflow Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryWorkflow: Codeunit "Library - Workflow";
        ApproverIdTok: Label 'MFGW-APPROVER', Locked = true;

    [Test]
    procedure TheTemplateIsCreatedOnce()
    var
        Workflow: Record Workflow;
        WorkflowStep: Record "Workflow Step";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
        StepCount: Integer;
    begin
        // [WHEN] The template is ensured twice
        WorkflowMgt.EnsureTemplate();
        Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(WorkflowMgt.TemplateCode()));
        WorkflowStep.SetRange("Workflow Code", Workflow.Code);
        StepCount := WorkflowStep.Count();
        WorkflowMgt.EnsureTemplate();

        // [THEN] One template, whose entry point is the engineering change event, and no duplicated steps
        Assert.IsTrue(Workflow.Template, 'The workflow is a template.');
        Assert.AreEqual(StepCount, WorkflowStep.Count(), 'Ensuring the template again adds no steps.');
        WorkflowStep.SetRange("Entry Point", true);
        WorkflowStep.FindFirst();
        Assert.AreEqual(WorkflowMgt.SendForApprovalEventCode(), WorkflowStep."Function Name", 'The workflow starts when a change is sent for approval.');
    end;

    [Test]
    procedure SubmittingWithoutAnEnabledWorkflowIsRefused()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] Approval through a workflow, but no enabled engineering change workflow
        Prepare();
        LibraryWorkflow.DisableAllWorkflows();
        CreateChange(EcoHeader, 'MFGW-001');

        // [WHEN] The change is sent for approval
        asserterror Engine.SubmitForApproval(EcoHeader);

        // [THEN] It is refused and stays open
        Assert.ExpectedError('No enabled approval workflow');
    end;

    [Test]
    procedure ApprovingOnTheCardIsRefusedUnderAWorkflow()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] Approval through a workflow, and a change pending approval
        Prepare();
        CreateChange(EcoHeader, 'MFGW-002');
        EcoHeader.Status := EcoHeader.Status::MFGPendingApproval;
        EcoHeader.Modify(false);

        // [WHEN] It is approved on the card
        asserterror Engine.Approve(EcoHeader);

        // [THEN] It is refused: approvers decide in Requests to Approve
        Assert.ExpectedError('Requests to Approve');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TheWorkflowApprovesTheChange()
    var
        EcoHeader: Record "MFG ECO Header";
        ApprovalEntry: Record "Approval Entry";
        Engine: Codeunit "MFG ECO Engine";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        // [GIVEN] An enabled engineering change workflow with its own approver (a request whose approver is the sender
        // is approved at once, as Business Central does)
        Prepare();
        CreateEnabledWorkflow();
        CreateChange(EcoHeader, 'MFGW-003');

        // [WHEN] The change is sent for approval
        Engine.SubmitForApproval(EcoHeader);

        // [THEN] It is pending, with an open approval entry for the approver carrying its number
        Assert.AreEqual(EcoHeader.Status::MFGPendingApproval, EcoHeader.Status, 'The workflow sets the change to pending approval.');
        ApprovalEntry.SetRange("Record ID to Approve", EcoHeader.RecordId());
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        Assert.RecordCount(ApprovalEntry, 1);
        ApprovalEntry.FindFirst();
        Assert.AreEqual(EcoHeader."No.", ApprovalEntry."Document No.", 'The approval entry names the change.');
        Assert.AreEqual(ApproverIdTok, ApprovalEntry."Approver ID", 'The request goes to the workflow''s approver.');

        // [WHEN] The approver approves the request
        ActAsApprover(EcoHeader);
        ApprovalsMgmt.ApproveRecordApprovalRequest(EcoHeader.RecordId());

        // [THEN] The change is approved by the approver
        EcoHeader.Get(EcoHeader."No.");
        Assert.AreEqual(EcoHeader.Status::MFGApproved, EcoHeader.Status, 'The last approval approves the change.');
        Assert.AreEqual(UserId(), EcoHeader."Approved By", 'The user who gave the last approval is recorded.');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure RejectingInTheWorkflowReopensTheChange()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        // [GIVEN] A change sent for approval through an enabled workflow
        Prepare();
        CreateEnabledWorkflow();
        CreateChange(EcoHeader, 'MFGW-004');
        Engine.SubmitForApproval(EcoHeader);

        // [WHEN] The approver rejects the request
        ActAsApprover(EcoHeader);
        ApprovalsMgmt.RejectRecordApprovalRequest(EcoHeader.RecordId());

        // [THEN] The change is open again, as standard documents are after a rejection
        EcoHeader.Get(EcoHeader."No.");
        Assert.AreEqual(EcoHeader.Status::MFGOpen, EcoHeader.Status, 'A rejected request reopens the change.');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ReopeningCancelsThePendingRequest()
    var
        EcoHeader: Record "MFG ECO Header";
        ApprovalEntry: Record "Approval Entry";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] A change sent for approval through an enabled workflow
        Prepare();
        CreateEnabledWorkflow();
        CreateChange(EcoHeader, 'MFGW-005');
        Engine.SubmitForApproval(EcoHeader);

        // [WHEN] The requester reopens it
        Engine.Reopen(EcoHeader);

        // [THEN] It is open, and its approval request is canceled
        Assert.AreEqual(EcoHeader.Status::MFGOpen, EcoHeader.Status, 'Reopening opens the change.');
        ApprovalEntry.SetRange("Record ID to Approve", EcoHeader.RecordId());
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        Assert.RecordIsEmpty(ApprovalEntry);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure Prepare()
    var
        Setup: Record "MFG ECO Setup";
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := true;
        Setup."Separate Approver" := false;
        Setup."Approval Method" := Setup."Approval Method"::MFGWorkflow;
        Setup.Modify(true);
        FeatureSetup.EnsureNoSeries(Setup);
    end;

    local procedure CreateEnabledWorkflow()
    var
        Workflow: Record Workflow;
        WorkflowMgt: Codeunit "MFG ECO Workflow Mgt.";
    begin
        EnsureUserSetup(CopyStr(UserId(), 1, 50));
        EnsureUserSetup(ApproverIdTok);

        LibraryWorkflow.DisableAllWorkflows();
        WorkflowMgt.EnsureTemplate();
        LibraryWorkflow.CopyWorkflowTemplate(Workflow, WorkflowMgt.TemplateCode());
        LibraryWorkflow.SetWorkflowSpecificApprover(Workflow.Code, ApproverIdTok);
        LibraryWorkflow.EnableWorkflow(Workflow);
    end;

    local procedure EnsureUserSetup(UserCode: Code[50])
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserCode) then
            exit;
        UserSetup.Init();
        UserSetup."User ID" := UserCode;
        UserSetup."Approval Administrator" := true;
        UserSetup.Insert(false);
    end;

    /// <summary>
    /// Hands the open request to the current user, as Microsoft's own approval tests do, so the test session can
    /// act as the approver.
    /// </summary>
    local procedure ActAsApprover(EcoHeader: Record "MFG ECO Header")
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Record ID to Approve", EcoHeader.RecordId());
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.ModifyAll("Approver ID", CopyStr(UserId(), 1, MaxStrLen(ApprovalEntry."Approver ID")), false);
    end;

    local procedure CreateChange(var EcoHeader: Record "MFG ECO Header"; EcoNo: Code[20])
    var
        EcoLine: Record "MFG ECO Line";
    begin
        EcoHeader.Init();
        EcoHeader."No." := EcoNo;
        EcoHeader."Effective Date" := WorkDate();
        EcoHeader.Insert(true);

        EcoLine.Init();
        EcoLine."ECO No." := EcoNo;
        EcoLine."Line No." := 10000;
        EcoLine."Object Type" := EcoLine."Object Type"::MFGProductionBom;
        EcoLine."No." := 'MFGW-BOM';
        EcoLine."New Version Code" := 'V2';
        EcoLine.Insert(false);
    end;
}
