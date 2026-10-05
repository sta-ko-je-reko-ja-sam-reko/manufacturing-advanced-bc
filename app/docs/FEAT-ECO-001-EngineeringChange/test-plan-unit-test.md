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
| TEST-14 | The template ensured twice / one template starting with the ECO event, no duplicated steps (ECO-002) | `MFG ECO Workflow Tests.TheTemplateIsCreatedOnce` |
| TEST-15 | Workflow method, no enabled workflow / sent for approval / refused | `MFG ECO Workflow Tests.SubmittingWithoutAnEnabledWorkflowIsRefused` |
| TEST-16 | Workflow method, a pending change / approved on the card / refused, use Requests to Approve | `MFG ECO Workflow Tests.ApprovingOnTheCardIsRefusedUnderAWorkflow` |
| TEST-17 | An implemented change; a firm planned order due later with two lines, one due before the effective date, a released one with posted entries, a released one without / impacted orders refreshed through a fake / two refreshed once each, two left alone (ECO-003) | `OnlyImpactedOrdersThatCanTakeTheChangeAreRefreshed` |
| TEST-18 | An approved change / impacted orders refreshed / refused until implemented | `RefreshingImpactedOrdersNeedsAnImplementedChange` |
