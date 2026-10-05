# FEAT-PLN-001 - Planning Insight

Unit test plan. Automated in `MFG Planning Tests` (codeunit 89011). Requisition lines are inserted directly in batch
`MFGP-TMPL` / `MFGP-BATCH` with fixed `MFGP-*` items.

| Case | Given / When / Then | Automation |
|---|---|---|
| TEST-01 | A batch with two messages and one blank line / recorded / one run with two messages | `RecordingABatchStoresItsActionMessages` |
| TEST-02 | A batch without messages / recorded / nothing | `ABatchWithoutMessagesRecordsNothing` |
| TEST-03 | Three runs rescheduling one item, twice in the first / analysed / three runs, not four | `AnalysisCountsRunsNotMessages` |
| TEST-04 | An item without dampener, rescheduled in three runs, threshold three / analysed / dampener period advice | `RepeatedReschedulesAdviseADampenerPeriod` |
| TEST-05 | Two runs, threshold three / analysed / no advice | `BelowTheThresholdThereIsNoAdvice` |
| TEST-06 | Cancel and New in three runs / analysed / cancel-and-new pattern | `CancelAndNewAdviseLongerPeriods` |
| TEST-07 | Rescheduling rule inactive / analysed / no advice | `AnInactiveRuleGivesNoAdvice` |
| TEST-08 | Planning finishes with the feature off, then on / nothing, then one run | `TheReactionsRecordOnlyWhileTheFeatureIsOn` |
| TEST-09 | The feature's guided setup step / step 60 opening the setup page | `TheFeatureRegistersAGuidedSetupStep` |
| TEST-10 | Sample data twice / three rules and the package once | `ImportingSampleDataBuildsThePackage` |

All automated in `MFG Planning Tests`.
