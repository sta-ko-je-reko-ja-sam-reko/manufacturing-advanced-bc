# FEAT-CORE-001 - Foundation

Unit test plan. Automated in `MFG Foundation Tests` (codeunit 89000) with the fake `MFG Test Setup Logic`
(codeunit 89001).

## TEST-01 — The none value is never enabled
- **Given** the `MFGNone` value of the feature enum
- **When** the facade is asked whether it is enabled
- **Then** it answers no

**Automation:** `MFG Foundation Tests.TheNoneValueIsNeverEnabled`

## TEST-02 — Every feature value answers
- **Given** every value of the feature enum
- **When** each is asked whether it is enabled
- **Then** each answers, through its own implementation or the default one

**Automation:** `MFG Foundation Tests.EveryFeatureValueAnswersWhetherItIsSwitchedOn`

## TEST-03 — CheckEnabled refuses a feature that is off
- **Given** a feature that is switched off
- **When** `CheckEnabled` is called, as a writable API page does before every write
- **Then** an error says the feature is not enabled

**Automation:** `MFG Foundation Tests.CheckEnabledRefusesAFeatureThatIsOff`

## TEST-04 — The setup record is created once
- **Given** no foundation setup record
- **When** it is ensured twice
- **Then** exactly one record exists

**Automation:** `MFG Foundation Tests.EnsureExistsCreatesTheSetupRecordOnce`

## TEST-05 — Define replaces the setup logic
- **Given** a fake `MFG ISetup` implementation injected with `Define()`
- **When** the setup record is ensured
- **Then** the fake ran and no record was written

**Automation:** `MFG Foundation Tests.DefineReplacesTheSetupLogic`

## TEST-06 — The guided setup lists the foundation first
- **Given** the foundation record exists
- **When** the guided setup list is built
- **Then** step 10 is the foundation, it has no toggle, it opens the foundation setup page, and it is completed

**Automation:** `MFG Foundation Tests.GuidedSetupListsTheFoundationFirst`

## TEST-07 — The foundation step is not started without its record
- **Given** no foundation record
- **When** the guided setup list is built
- **Then** the foundation step is not started

**Automation:** `MFG Foundation Tests.FoundationStepIsNotStartedWithoutItsRecord`

## TEST-08 — Finishing the foundation step creates the record
- **Given** no foundation record
- **When** the wizard is finished on the foundation step
- **Then** the foundation record exists

**Automation:** `MFG Foundation Tests.FinishingTheFoundationStepCreatesTheSetupRecord`

## TEST-09 — A number series is created once
- **Given** a series code that does not exist
- **When** it is ensured twice
- **Then** one series with one line exists, giving out numbers by default

**Automation:** `MFG Foundation Tests.EnsureSeriesCreatesASeriesOnce`

## TEST-10 — Creating a configuration package is idempotent
- **Given** a package code that does not exist
- **When** the package is created twice
- **Then** only the first call creates it

**Automation:** `MFG Foundation Tests.CreatePackageIsIdempotent`

## TEST-11 — An extended standard table carries only its key and the app's fields
- **Given** a new package
- **When** the Item table is added with one named field
- **Then** only the primary key and that field are included

**Automation:** `MFG Foundation Tests.AnExtendedTableCarriesOnlyItsKeyAndTheAppsFields`

## TEST-12 — An own table carries every field
- **Given** a new package
- **When** a table the app owns is added
- **Then** none of its fields is left out

**Automation:** `MFG Foundation Tests.AnOwnTableCarriesEveryField`
