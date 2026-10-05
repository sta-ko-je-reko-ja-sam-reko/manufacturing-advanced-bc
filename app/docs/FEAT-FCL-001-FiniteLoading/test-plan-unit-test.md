# FEAT-FCL-001 - Finite Loading

Unit test plan. Automated in `MFG Loading Tests` (codeunit 89018) with the fake capacity source `MFG Test Capacity
Source` (codeunit 89019, 480 minutes a day) injected through the locator, work center `MFGL-WC` in minutes, and
firm planned operations inserted directly.

| Case | Given / When / Then | Automation |
|---|---|---|
| TEST-01 | A due in 5 days needs 600, B due tomorrow needs 300 / calculated / B first finishing today; A starts today, finishes tomorrow, not late | `TheOrderDueFirstIsLoadedFirst` |
| TEST-02 | An order due today needs 600 / calculated / late by one day | `AnOperationFinishingAfterItsDueDateIsLate` |
| TEST-03 | Shortest first, D needs 600 due today, E needs 100 due later / calculated / E first | `ShortestFirstLoadsTheSmallestOperationFirst` |
| TEST-04 | By order number, G due today, F due later / calculated / F first | `OrderNumberLoadsFirstInFirstOut` |
| TEST-05 | A one-day horizon of 480, an operation of 600 / calculated / does not fit, late | `WorkBeyondTheHorizonDoesNotFit` |
| TEST-06 | Two calendar entries of 240 today / the calendar source asked / 480 | `TheCalendarSourceSumsTheDaysEntries` |
| TEST-07 | The feature off / calculated / refused | `CalculatingIsRefusedWhileTheFeatureIsOff` |
| TEST-08 | The feature's guided setup step / step 90 opening the setup page | `TheFeatureRegistersAGuidedSetupStep` |
| TEST-09 | Sample data twice / the package exists | `ImportingSampleDataBuildsThePackage` |
