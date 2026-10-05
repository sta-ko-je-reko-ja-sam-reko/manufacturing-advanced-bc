namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;
using ManufacturingAdvanced.EngineeringChange;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.WIPControl;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 89000 "MFG Foundation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TheActivitiesCountWhatNeedsAttention()
    var
        TempCue: Record "MFG Activities Cue" temporary;
        PreflightFinding: Record "MFG Preflight Finding";
        FinishProposal: Record "MFG Finish Proposal";
        EcoHeader: Record "MFG ECO Header";
        CueCalc: Codeunit "MFG Activities Cue Calc";
        Before: Dictionary of [Text, Text];
        After: Dictionary of [Text, Text];
    begin
        // [GIVEN] The counts as they are
        CueCalc.CollectCounts(Before);

        // [WHEN] A pre-flight error, a finish proposal ready to finish and a change pending approval are added
        PreflightFinding.Init();
        PreflightFinding.Severity := PreflightFinding.Severity::MFGError;
        PreflightFinding."Prod. Order No." := 'MFGF-CUE';
        PreflightFinding.Insert(false);
        FinishProposal.Init();
        FinishProposal."Prod. Order No." := 'MFGF-CUE';
        FinishProposal.Status := FinishProposal.Status::MFGReady;
        FinishProposal.Insert(false);
        EcoHeader.Init();
        EcoHeader."No." := 'MFGF-CUE';
        EcoHeader.Status := EcoHeader.Status::MFGPendingApproval;
        EcoHeader.Insert(false);
        CueCalc.CollectCounts(After);

        // [THEN] Each of those cues counts one more, and every cue has a count
        Assert.AreEqual(Count(Before, TempCue.FieldNo("Preflight Errors")) + 1, Count(After, TempCue.FieldNo("Preflight Errors")), 'The pre-flight error is counted.');
        Assert.AreEqual(Count(Before, TempCue.FieldNo("Orders Ready to Finish")) + 1, Count(After, TempCue.FieldNo("Orders Ready to Finish")), 'The ready order is counted.');
        Assert.AreEqual(Count(Before, TempCue.FieldNo("ECOs Pending Approval")) + 1, Count(After, TempCue.FieldNo("ECOs Pending Approval")), 'The pending change is counted.');
        Assert.AreEqual(Count(Before, TempCue.FieldNo("ECOs to Implement")), Count(After, TempCue.FieldNo("ECOs to Implement")), 'A pending change is not one to implement.');
        Assert.AreEqual(10, After.Count(), 'Every cue gets a count.');
    end;

    local procedure Count(Results: Dictionary of [Text, Text]; CueFieldNo: Integer) Value: Integer
    begin
        Evaluate(Value, Results.Get(Format(CueFieldNo)));
    end;

    [Test]
    procedure TheNoneValueIsNeverEnabled()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Feature: Enum "MFG Feature";
    begin
        // [SCENARIO] The none value exists so that an unbound enum value fails safe. It must never report
        // itself as an enabled feature, or the setup list would offer a step for something that is not one.
        Assert.IsFalse(FeatureMgt.IsEnabled(Feature::MFGNone), 'The none value is not a feature and is never enabled.');
    end;

    [Test]
    procedure EveryFeatureValueAnswersWhetherItIsSwitchedOn()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Ordinal: Integer;
        Answered: Integer;
    begin
        // [SCENARIO] A feature ships by adding a value to the feature enum. A value with no implementation
        // bound to it must still answer, through the default implementation, instead of failing at runtime.
        foreach Ordinal in Enum::"MFG Feature".Ordinals() do begin
            if FeatureMgt.IsEnabled(Enum::"MFG Feature".FromInteger(Ordinal)) then;
            Answered += 1;
        end;

        Assert.AreEqual(Enum::"MFG Feature".Ordinals().Count(), Answered, 'Every value of the feature enum should answer.');
    end;

    [Test]
    procedure CheckEnabledRefusesAFeatureThatIsOff()
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Feature: Enum "MFG Feature";
    begin
        // [SCENARIO] A writable API page calls CheckEnabled before every write, so an agent cannot write to a
        // feature that is switched off.
        asserterror FeatureMgt.CheckEnabled(Feature::MFGNone);

        Assert.ExpectedError('is not enabled');
    end;

    [Test]
    procedure EnsureExistsCreatesTheSetupRecordOnce()
    var
        Setup: Record "MFG Setup";
    begin
        // [GIVEN] No foundation setup record
        Setup.DeleteAll();

        // [WHEN] The record is ensured twice
        Setup.EnsureExists();
        Setup.EnsureExists();

        // [THEN] Exactly one record exists
        Assert.RecordCount(Setup, 1);
    end;

    [Test]
    procedure DefineReplacesTheSetupLogic()
    var
        Setup: Record "MFG Setup";
        TestSetupLogic: Codeunit "MFG Test Setup Logic";
    begin
        // [GIVEN] No foundation setup record, and a replacement implementation of the setup logic
        Setup.DeleteAll();
        TestSetupLogic.Reset();
        Setup.Define(TestSetupLogic);

        // [WHEN] The record is ensured
        Setup.EnsureExists();

        // [THEN] The replacement ran instead of the default, so no record was written
        Assert.AreEqual(1, TestSetupLogic.GetEnsureExistsCalls(), 'The injected implementation should have been called once.');
        Assert.RecordIsEmpty(Setup);
    end;

    [Test]
    procedure GuidedSetupListsTheFoundationFirst()
    var
        Setup: Record "MFG Setup";
        TempSetupStep: Record "MFG Setup Step" temporary;
        GuidedSetup: Codeunit "MFG Guided Setup";
    begin
        // [GIVEN] The foundation setup record exists
        Setup.EnsureExists();

        // [WHEN] The guided setup list is built
        GuidedSetup.PopulateSteps(TempSetupStep);

        // [THEN] The first step is the always-on foundation, and it is complete
        TempSetupStep.FindFirst();
        Assert.AreEqual(10, TempSetupStep."Step No.", 'The foundation should be the first step.');
        Assert.IsFalse(TempSetupStep."Has Toggle", 'The foundation cannot be switched off.');
        Assert.AreEqual(Page::"MFG Setup", TempSetupStep."Setup Page ID", 'The foundation step should open the foundation setup page.');
        Assert.AreEqual(TempSetupStep.Status::MFGCompleted, TempSetupStep.Status, 'The foundation is complete once its record exists.');
    end;

    [Test]
    procedure FoundationStepIsNotStartedWithoutItsRecord()
    var
        Setup: Record "MFG Setup";
        TempSetupStep: Record "MFG Setup Step" temporary;
        GuidedSetup: Codeunit "MFG Guided Setup";
    begin
        // [GIVEN] No foundation setup record
        Setup.DeleteAll();

        // [WHEN] The guided setup list is built
        GuidedSetup.PopulateSteps(TempSetupStep);

        // [THEN] The foundation step reports that it has not been started
        TempSetupStep.FindFirst();
        Assert.AreEqual(TempSetupStep.Status::MFGNotStarted, TempSetupStep.Status, 'The foundation is not started while its record is missing.');
    end;

    [Test]
    procedure FinishingTheFoundationStepCreatesTheSetupRecord()
    var
        Setup: Record "MFG Setup";
        TempSetupStep: Record "MFG Setup Step" temporary;
        GuidedSetup: Codeunit "MFG Guided Setup";
    begin
        // [GIVEN] No foundation setup record, and the guided setup list
        Setup.DeleteAll();
        GuidedSetup.PopulateSteps(TempSetupStep);
        TempSetupStep.FindFirst();

        // [WHEN] The wizard is finished on the foundation step
        GuidedSetup.ApplyWizardChoices(TempSetupStep, false, false, false);

        // [THEN] The foundation setup record exists
        Assert.IsTrue(Setup.IsComplete(), 'Finishing the foundation step should create the setup record.');
    end;

    [Test]
    procedure EnsureSeriesCreatesASeriesOnce()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit "MFG No. Series Mgt.";
        SeriesCode: Code[20];
    begin
        // [GIVEN] A series code that does not exist
        SeriesCode := 'MFG-TEST';
        if NoSeries.Get(SeriesCode) then
            NoSeries.Delete(true);

        // [WHEN] The series is ensured twice
        Assert.AreEqual(SeriesCode, NoSeriesMgt.EnsureSeries(SeriesCode, 'Test series', 'MT00001', 'MT99999'), 'The series code should be returned.');
        Assert.AreEqual(SeriesCode, NoSeriesMgt.EnsureSeries(SeriesCode, 'Test series', 'MT00001', 'MT99999'), 'The series code should be returned again.');

        // [THEN] One series with one line exists
        NoSeriesLine.SetRange("Series Code", SeriesCode);
        Assert.RecordCount(NoSeriesLine, 1);
        NoSeries.Get(SeriesCode);
        Assert.IsTrue(NoSeries."Default Nos.", 'The series should give out numbers by default.');
    end;

    [Test]
    procedure CreatePackageIsIdempotent()
    var
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
        PackageCode: Code[20];
    begin
        // [GIVEN] A package code that does not exist
        PackageCode := 'MFG-TEST';
        DeletePackage(PackageCode);

        // [WHEN] The package is created twice
        // [THEN] Only the first call creates it
        Assert.IsTrue(ConfigPackageMgt.CreatePackage(PackageCode, 'Test package'), 'The first call should create the package.');
        Assert.IsFalse(ConfigPackageMgt.CreatePackage(PackageCode, 'Test package'), 'The second call should find the package and create nothing.');
    end;

    [Test]
    procedure AnExtendedTableCarriesOnlyItsKeyAndTheAppsFields()
    var
        Item: Record Item;
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
        FieldNos: List of [Integer];
        PackageCode: Code[20];
    begin
        // [GIVEN] A new package
        PackageCode := 'MFG-TEST';
        DeletePackage(PackageCode);
        ConfigPackageMgt.CreatePackage(PackageCode, 'Test package');

        // [WHEN] A standard table is added with one field standing in for a field this app adds to it
        FieldNos.Add(Item.FieldNo(Description));
        ConfigPackageMgt.AddExtendedTable(PackageCode, Database::Item, FieldNos);

        // [THEN] Only the primary key and that field are included
        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", Database::Item);
        ConfigPackageField.SetRange("Include Field", true);
        Assert.RecordCount(ConfigPackageField, 2);
        ConfigPackageField.SetRange("Field ID", Item.FieldNo(Description));
        Assert.RecordIsNotEmpty(ConfigPackageField);
    end;

    [Test]
    procedure AnOwnTableCarriesEveryField()
    var
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageMgt: Codeunit "MFG Config. Package Mgt.";
        PackageCode: Code[20];
    begin
        // [GIVEN] A new package
        PackageCode := 'MFG-TEST';
        DeletePackage(PackageCode);
        ConfigPackageMgt.CreatePackage(PackageCode, 'Test package');

        // [WHEN] A table this app owns is added
        ConfigPackageMgt.AddOwnTable(PackageCode, Database::"MFG Demo Data");

        // [THEN] No field of it is left out
        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", Database::"MFG Demo Data");
        Assert.RecordIsNotEmpty(ConfigPackageField);
        ConfigPackageField.SetRange("Include Field", false);
        Assert.RecordIsEmpty(ConfigPackageField);
    end;

    local procedure DeletePackage(PackageCode: Code[20])
    var
        ConfigPackage: Record "Config. Package";
    begin
        if ConfigPackage.Get(PackageCode) then
            ConfigPackage.Delete(true);
    end;
}
