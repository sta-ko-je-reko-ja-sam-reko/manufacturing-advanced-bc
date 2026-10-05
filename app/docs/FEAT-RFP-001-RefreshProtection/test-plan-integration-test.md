# FEAT-RFP-001 - Refresh Protection

Integration test plan. Automated in `MFG Refresh Integration` (codeunit 89008) with `Library - Manufacturing`, whose
`RefreshProdOrder` runs the real *Refresh Production Order* report, so the report's events fire.

## TEST-01 — A refresh discards a manual quantity and Restore brings it back
- **Given** the feature on, and a refreshed order whose component quantity per was changed to 5 by hand
- **When** the components are recalculated by the report
- **Then** the quantity per is 1 again and one change was recorded; after Restore it is 5

**Automation:** `MFG Refresh Integration.ARefreshDiscardsAManualQuantityAndRestoreBringsItBack`

## TEST-02 — A refresh removes a manual component and Restore re-creates it
- **Given** the feature on, and a refreshed order with a component added by hand, quantity per 2
- **When** the components are recalculated
- **Then** the component is gone and one removal was recorded; after Restore it is back with quantity per 2

**Automation:** `MFG Refresh Integration.ARefreshRemovesAManualComponentAndRestoreRecreatesIt`

## TEST-03 — Nothing is recorded while the feature is off
- **Given** the feature off, and a refreshed order with a manual quantity
- **When** the components are recalculated
- **Then** no run

**Automation:** `MFG Refresh Integration.NothingIsRecordedWhileTheFeatureIsOff`

## TEST-04 — The notification in the client
- **Given** the feature on with notifications
- **When** a planner refreshes an order with a manual change from the order card
- **Then** the notification shows the number of changes and *Show changes* opens them

**Automation:** manual, on `bc29loc`

## TEST-05 — The API and MCP configuration
- **Given** the feature enabled
- **When** an agent bound to *Manufacturing Advanced - Refresh Protection* reads `refreshChanges` and calls `restore`
- **Then** the change is restored; a change that is not restorable, already restored, or with the feature off, is refused

**Automation:** manual, on `bc29loc`

## TEST-06 — A recalculation outside the batch job is recorded (RFP-003)
- **Given** refresh protection on, and a refreshed order whose component quantity per was set to 5 by hand
- **When** the line is recalculated directly with `Calculate Prod. Order`.Calculate
- **Then** the quantity per is 1 again, and a run with source *Recalculation of a line* recorded the change

**Automation:** `MFG Refresh Integration.ARecalculationOutsideTheBatchJobIsRecorded`
