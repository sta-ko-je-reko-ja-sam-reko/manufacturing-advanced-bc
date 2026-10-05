# FEAT-ECO-001 - Engineering Change

Unit test plan. Automated in `MFG ECO Tests` (codeunit 89016). Changes are created with fixed `MFGE-*` numbers.

| Case | Given / When / Then | Automation |
|---|---|---|
| TEST-01 | A setup with a number series / a change inserted without a number / numbered from the series, open, requested by the user | `ANewChangeIsNumberedFromTheSeries` |
| TEST-02 | No effective date / sent for approval / refused | `SubmittingWithoutAnEffectiveDateIsRefused` |
| TEST-03 | A line without its version / sent for approval / refused | `SubmittingALineWithoutItsVersionIsRefused` |
| TEST-04 | An open change / approved / refused, not pending | `ApprovingAnOpenChangeIsRefused` |
| TEST-05 | Separate approver required, submitted by the user / approved by the same user / refused | `TheRequesterCannotApproveWhenASeparateApproverIsRequired` |
| TEST-06 | No separate approver / approved by the requester / approved, approver recorded | `TheRequesterCanApproveWhenNoSeparateApproverIsRequired` |
| TEST-07 | A submitted change / rejected, reopened / open, approval cleared | `RejectingAndReopeningReturnsTheChangeToOpen` |
| TEST-08 | An approved change / deleted / refused | `AnApprovedChangeCannotBeDeleted` |
| TEST-09 | An open change with a line / deleted / lines gone | `DeletingAnOpenChangeDeletesItsLines` |
| TEST-10 | A line without a type / a number entered / refused | `ALineWithoutATypeRefusesANumber` |
| TEST-11 | The feature off / versions created / refused | `TheChangeIsRefusedWhileTheFeatureIsOff` |
| TEST-12 | The guided setup / step and wizard with numbering / step 80 with numbering, series MFG-ECO assigned | `TheFeatureOffersANumberSeriesInTheGuidedSetup` |
| TEST-13 | Sample data twice / one sample change at most, package exists | `ImportingSampleDataTwiceCreatesItOnce` |
