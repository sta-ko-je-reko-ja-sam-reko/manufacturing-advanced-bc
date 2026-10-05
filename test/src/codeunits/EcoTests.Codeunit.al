namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.EngineeringChange;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89016 "MFG ECO Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure ANewChangeIsNumberedFromTheSeries()
    var
        EcoHeader: Record "MFG ECO Header";
    begin
        // [GIVEN] The setup has a number series
        Prepare(false);

        // [WHEN] A change is inserted without a number
        EcoHeader.Init();
        EcoHeader.Insert(true);

        // [THEN] It is numbered, open, and requested by the current user
        Assert.IsTrue(CopyStr(EcoHeader."No.", 1, 3) = 'ECO', 'The number comes from the series.');
        Assert.AreEqual(EcoHeader.Status::MFGOpen, EcoHeader.Status, 'A new change is open.');
        Assert.AreEqual(UserId(), EcoHeader."Requested By", 'The requester is recorded.');
    end;

    [Test]
    procedure SubmittingWithoutAnEffectiveDateIsRefused()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] An open change with a line that has its version, but no effective date
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-001', 0D, 'V1');

        // [WHEN] It is sent for approval
        asserterror Engine.SubmitForApproval(EcoHeader);

        // [THEN] It is refused
        Assert.ExpectedError('Enter the effective date');
    end;

    [Test]
    procedure SubmittingALineWithoutItsVersionIsRefused()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] An open change with an effective date and a line without its new version
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-002', WorkDate(), '');

        // [WHEN] It is sent for approval
        asserterror Engine.SubmitForApproval(EcoHeader);

        // [THEN] It is refused
        Assert.ExpectedError('has no new version yet');
    end;

    [Test]
    procedure ApprovingAnOpenChangeIsRefused()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] An open change
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-003', WorkDate(), 'V1');

        // [WHEN] It is approved
        asserterror Engine.Approve(EcoHeader);

        // [THEN] It is refused because it is not pending
        Assert.ExpectedError('This step needs it to be');
    end;

    [Test]
    procedure TheRequesterCannotApproveWhenASeparateApproverIsRequired()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] A separate approver is required, and a change the current user submitted
        Prepare(true);
        CreateChange(EcoHeader, 'MFGE-004', WorkDate(), 'V1');
        Engine.SubmitForApproval(EcoHeader);

        // [WHEN] The same user approves it
        asserterror Engine.Approve(EcoHeader);

        // [THEN] It is refused
        Assert.ExpectedError('someone else must approve it');
    end;

    [Test]
    procedure TheRequesterCanApproveWhenNoSeparateApproverIsRequired()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] No separate approver is required, and a submitted change
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-005', WorkDate(), 'V1');
        Engine.SubmitForApproval(EcoHeader);

        // [WHEN] The requester approves it
        Engine.Approve(EcoHeader);

        // [THEN] It is approved by them
        Assert.AreEqual(EcoHeader.Status::MFGApproved, EcoHeader.Status, 'The change is approved.');
        Assert.AreEqual(UserId(), EcoHeader."Approved By", 'The approver is recorded.');
    end;

    [Test]
    procedure RejectingAndReopeningReturnsTheChangeToOpen()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] A submitted change
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-006', WorkDate(), 'V1');
        Engine.SubmitForApproval(EcoHeader);

        // [WHEN] It is rejected, then reopened
        Engine.Reject(EcoHeader);
        Assert.AreEqual(EcoHeader.Status::MFGRejected, EcoHeader.Status, 'The change is rejected.');
        Engine.Reopen(EcoHeader);

        // [THEN] It is open again, with the approval cleared
        Assert.AreEqual(EcoHeader.Status::MFGOpen, EcoHeader.Status, 'The change is open again.');
        Assert.AreEqual('', EcoHeader."Approved By", 'The approval is cleared.');
    end;

    [Test]
    procedure AnApprovedChangeCannotBeDeleted()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] An approved change
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-007', WorkDate(), 'V1');
        Engine.SubmitForApproval(EcoHeader);
        Engine.Approve(EcoHeader);

        // [WHEN] It is deleted
        asserterror EcoHeader.Delete(true);

        // [THEN] It is refused
        Assert.ExpectedError('cannot be deleted');
    end;

    [Test]
    procedure DeletingAnOpenChangeDeletesItsLines()
    var
        EcoHeader: Record "MFG ECO Header";
        EcoLine: Record "MFG ECO Line";
    begin
        // [GIVEN] An open change with a line
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-008', WorkDate(), 'V1');

        // [WHEN] It is deleted
        EcoHeader.Delete(true);

        // [THEN] Its lines are gone too
        EcoLine.SetRange("ECO No.", 'MFGE-008');
        Assert.RecordIsEmpty(EcoLine);
    end;

    [Test]
    procedure ALineWithoutATypeRefusesANumber()
    var
        EcoLine: Record "MFG ECO Line";
    begin
        // [GIVEN] A line without a type
        EcoLine.Init();

        // [WHEN] A number is entered
        asserterror EcoLine.Validate("No.", 'ANY');

        // [THEN] It is refused
        Assert.ExpectedError('Choose whether the line changes');
    end;

    [Test]
    procedure TheChangeIsRefusedWhileTheFeatureIsOff()
    var
        EcoHeader: Record "MFG ECO Header";
        Engine: Codeunit "MFG ECO Engine";
    begin
        // [GIVEN] An open change, and the feature off
        Prepare(false);
        CreateChange(EcoHeader, 'MFGE-009', WorkDate(), 'V1');
        SetFeature(false, false);

        // [WHEN] Its versions are created
        asserterror Engine.CreateVersions(EcoHeader);

        // [THEN] It is refused
        Assert.ExpectedError('is not enabled');
    end;

    [Test]
    procedure TheFeatureOffersANumberSeriesInTheGuidedSetup()
    var
        TempSetupStep: Record "MFG Setup Step" temporary;
        Setup: Record "MFG ECO Setup";
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
    begin
        // [WHEN] The feature registers its step and the wizard creates the number series
        FeatureSetup.RegisterStep(TempSetupStep);
        FeatureSetup.EnsureSetup(Setup);
        Setup."ECO Nos." := '';
        Setup.Modify(true);
        FeatureSetup.ApplyChoices(true, true, false);

        // [THEN] Step 80 offers numbering, and the setup now numbers changes from MFG-ECO
        TempSetupStep.FindFirst();
        Assert.AreEqual(80, TempSetupStep."Step No.", 'Engineering change comes after the shop floor terminal.');
        Assert.IsTrue(TempSetupStep."Has No. Series", 'The feature numbers its orders.');
        Setup.Get();
        Assert.AreEqual('MFG-ECO', Setup."ECO Nos.", 'The wizard assigns the series.');
    end;

    [Test]
    procedure ImportingSampleDataTwiceCreatesItOnce()
    var
        EcoHeader: Record "MFG ECO Header";
        ConfigPackage: Record "Config. Package";
        DemoEco: Codeunit "MFG Demo ECO";
    begin
        // [WHEN] The sample data is imported twice
        DemoEco.Import();
        DemoEco.Import();

        // [THEN] At most one sample change and the configuration package
        EcoHeader.SetRange("No.", DemoEco.DemoEcoNo());
        Assert.IsTrue(EcoHeader.Count() <= 1, 'The sample change must not be duplicated.');
        Assert.IsTrue(ConfigPackage.Get('MFG-ECO'), 'Importing sample data should build the configuration package.');
    end;

    local procedure Prepare(SeparateApprover: Boolean)
    var
        Setup: Record "MFG ECO Setup";
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
    begin
        SetFeature(true, SeparateApprover);
        Setup.Get();
        FeatureSetup.EnsureNoSeries(Setup);
    end;

    local procedure CreateChange(var EcoHeader: Record "MFG ECO Header"; EcoNo: Code[20]; EffectiveDate: Date; NewVersionCode: Code[20])
    var
        EcoLine: Record "MFG ECO Line";
    begin
        EcoHeader.Init();
        EcoHeader."No." := EcoNo;
        EcoHeader."Effective Date" := EffectiveDate;
        EcoHeader.Insert(true);

        EcoLine.Init();
        EcoLine."ECO No." := EcoNo;
        EcoLine."Line No." := 10000;
        EcoLine."Object Type" := EcoLine."Object Type"::MFGProductionBom;
        EcoLine."No." := 'MFGE-BOM';
        EcoLine."New Version Code" := NewVersionCode;
        EcoLine.Insert(false);
    end;

    local procedure SetFeature(Enabled: Boolean; SeparateApprover: Boolean)
    var
        Setup: Record "MFG ECO Setup";
        FeatureSetup: Codeunit "MFG ECO Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Separate Approver" := SeparateApprover;
        Setup.Modify(true);
    end;
}
