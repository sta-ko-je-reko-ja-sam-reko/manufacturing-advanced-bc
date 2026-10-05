# FEAT-SFT-001 - Shop Floor Terminal

Unit test plan. Automated in `MFG Shop Floor Tests` (codeunit 89013) with the fake posting `MFG Test Shop Floor
Posting` (codeunit 89014) injected through the locator. Fixtures are inserted directly with fixed `MFGS-*` keys.

| Case | Given / When / Then | Automation |
|---|---|---|
| TEST-01 | An operation / started / a running session on the operation and its order line | `StartingAnOperationOpensASession` |
| TEST-02 | A running operation / started again / refused | `StartingTwiceIsRefused` |
| TEST-03 | An operation started 30 minutes ago / stopped / stopped with about 30 minutes | `StoppingRecordsTheMinutes` |
| TEST-04 | An operation never started / stopped / refused | `StoppingAnOperationThatIsNotRunningIsRefused` |
| TEST-05 | An operation that ran 20 minutes / 5 good and 1 scrap reported / one posting with quantities, scrap code and run minutes; session marked posted | `ReportingOutputPostsItWithTheClockedRunTime` |
| TEST-06 | An operation / zero good and zero scrap / refused, nothing posted | `ReportingNothingIsRefused` |
| TEST-07 | An operation / 45 minutes downtime with a stop code / a downtime posting with both | `ReportingDowntimePostsTheStopTime` |
| TEST-08 | The feature off / an operation is started / refused | `TheTerminalIsRefusedWhileTheFeatureIsOff` |
| TEST-09 | The feature's guided setup step / step 70 opening the setup page | `TheFeatureRegistersAGuidedSetupStep` |
| TEST-10 | Sample data twice / scrap code, stop code and package exist | `ImportingSampleDataCreatesTheCodesOnce` |
