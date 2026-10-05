# FEAT-RFP-001 - Refresh Protection

Unit test plan. Automated in `MFG Refresh Tests` (codeunit 89007). Fixtures are inserted directly with fixed `MFGR-*`
keys; the refresh is simulated between `BeginRun` and `CompleteRun`.

## TEST-01 — An unchanged order leaves no run
- **Given** an order with a component and an operation
- **When** a run is taken and completed with nothing changed
- **Then** no change, and the run is removed

**Automation:** `MFG Refresh Tests.AnUnchangedOrderLeavesNoRun`

## TEST-02 — A changed quantity per is recorded
- **Given** a component with quantity per 1
- **When** the refresh sets it to 2
- **Then** one restorable change on Quantity per, from 1 to 2

**Automation:** `MFG Refresh Tests.AChangedQuantityPerIsRecorded`

## TEST-03 — A removed component is recorded
- **Given** two components
- **When** the refresh removes one
- **Then** one restorable removal

**Automation:** `MFG Refresh Tests.ARemovedComponentIsRecorded`

## TEST-04 — An added component is recorded
- **Given** one component
- **When** the refresh adds another
- **Then** one addition pointing at the new line

**Automation:** `MFG Refresh Tests.AnAddedComponentIsRecorded`

## TEST-05 — The same item twice is matched by occurrence
- **Given** the same item twice on one line
- **When** only the second changes
- **Then** exactly one change, on the second line

**Automation:** `MFG Refresh Tests.TheSameItemTwiceIsMatchedByOccurrence`

## TEST-06 — A run time change is restorable, a work centre change is not
- **Given** an operation on WC1 with run time 5
- **When** the refresh moves it to WC2 with run time 7
- **Then** two changes; run time restorable, work centre not

**Automation:** `MFG Refresh Tests.ARunTimeChangeIsRestorableAWorkCentreChangeIsNot`

## TEST-07 — A removed operation is reported only
- **Given** two operations
- **When** the refresh removes one
- **Then** one removal that cannot be restored

**Automation:** `MFG Refresh Tests.ARemovedOperationIsReportedOnly`

## TEST-08 — Restoring a change that cannot be restored is refused
- **Given** the feature on and a work centre change
- **When** it is restored
- **Then** refused

**Automation:** `MFG Refresh Tests.RestoringAChangeThatCannotBeRestoredIsRefused`

## TEST-09 — Restoring is refused while the feature is off
- **Given** the feature off and a recorded component change
- **When** it is restored
- **Then** refused because the feature is not enabled

**Automation:** `MFG Refresh Tests.RestoringIsRefusedWhileTheFeatureIsOff`

## TEST-10 — Restoring an added component deletes it
- **Given** the feature on and a component the refresh added
- **When** the addition is restored
- **Then** the component is gone and the change is marked restored

**Automation:** `MFG Refresh Tests.RestoringAnAddedComponentDeletesIt`

## TEST-11 — The reactions record a run only while the feature is on
- **Given** an order with a component
- **When** a refresh changes it with the feature off, then again with it on
- **Then** nothing the first time; one run holding the change the second time

**Automation:** `MFG Refresh Tests.TheReactionsRecordARunOnlyWhileTheFeatureIsOn`

## TEST-12 — The feature registers a guided setup step
- **When** the feature is asked for its step
- **Then** step 40, with a toggle, opening the feature setup page

**Automation:** `MFG Refresh Tests.TheFeatureRegistersAGuidedSetupStep`

## TEST-13 — Importing sample data twice creates it once
- **When** the sample data is imported twice
- **Then** at most one sample order and run, and the configuration package

**Automation:** `MFG Refresh Tests.ImportingSampleDataTwiceCreatesItOnce`

## TEST-14 — A changed line quantity is recorded and restored (RFP-002)
- **Given** the feature on, and a line whose quantity the planner set to 8
- **When** the refresh sets it to 10, and the change is restored
- **Then** one restorable line change on Quantity, and the line has 8 again

**Automation:** `MFG Refresh Tests.AChangedLineQuantityIsRecordedAndRestored`

## TEST-15 — A renumbered line is matched, a changed BOM is reported only
- **Given** a line 10000 calculated from BOM MFGR-BOM1
- **When** the refresh recreates it as line 20000 from BOM MFGR-BOM2
- **Then** one Changed line change on Production BOM No., not restorable

**Automation:** `MFG Refresh Tests.ALineMatchedAfterRenumberingAndAChangedBomIsReportedOnly`

## TEST-16 — A removed line is reported only
- **Given** a second line for another item
- **When** the refresh removes it
- **Then** one Removed line change, not restorable

**Automation:** `MFG Refresh Tests.ARemovedLineIsReportedOnly`

## TEST-17 — A line recalculation outside the batch job is recorded (RFP-003)
- **Given** the feature on and a line with a component
- **When** the line events of a recalculation surround a change of its quantity per
- **Then** one run with source *Recalculation of a line* and one change

**Automation:** `MFG Refresh Tests.ALineRecalculationOutsideTheBatchJobIsRecorded`

## TEST-18 — A new line starts no run
- **Given** the feature on and a line without components or operations
- **When** it is calculated for the first time
- **Then** no run

**Automation:** `MFG Refresh Tests.ANewLineStartsNoRun`

## TEST-19 — A line recalculated by the batch job is left to its run
- **Given** the feature on and a line with a component
- **When** Refresh Production Order runs, and the line events fire inside it
- **Then** only the batch job's run, with the change once

**Automation:** `MFG Refresh Tests.ALineRecalculatedByTheBatchJobIsLeftToItsRun`
