# FEAT-WIP-001 - WIP Control

Unit test plan. Automated in `MFG WIP Tests` (codeunit 89004), with the fake valuation `MFG Test WIP Valuation`
(codeunit 89006). Fixtures are inserted directly with fixed `MFGW-*` keys.

## TEST-01 — An order with complete output is proposed
- **Given** a released order with no remaining quantity, last output five days before the work date
- **When** it is evaluated
- **Then** it is proposed as Ready, five days since output, with its finished quantity

**Automation:** `MFG WIP Tests.AnOrderWithCompleteOutputIsProposed`

## TEST-02 — An order with output missing is not proposed
- **Given** a released order with one unit still to output
- **When** it is evaluated
- **Then** no proposal

**Automation:** `MFG WIP Tests.AnOrderWithOutputMissingIsNotProposed`

## TEST-03 — The minimum days since output are respected
- **Given** a minimum of ten days and an order last output five days ago
- **When** it is evaluated
- **Then** no proposal yet

**Automation:** `MFG WIP Tests.TheMinimumDaysSinceOutputAreRespected`

## TEST-04 — WIP is consumption plus capacity minus output
- **Given** consumption 100, capacity 50, output 120
- **When** the order is evaluated
- **Then** the costs are 100, 50 and 120 and the estimated WIP is 30

**Automation:** `MFG WIP Tests.WipIsConsumptionPlusCapacityMinusOutput`

## TEST-05 — Missing consumption blocks the order
- **Given** a component with two units to consume
- **When** the order is evaluated
- **Then** Blocked, with the component named in the notes

**Automation:** `MFG WIP Tests.MissingConsumptionBlocksTheOrder`

## TEST-06 — An open pick blocks the order
- **Given** an open pick line for the order's components
- **When** the order is evaluated
- **Then** Blocked

**Automation:** `MFG WIP Tests.AnOpenPickBlocksTheOrder`

## TEST-07 — An unfinished operation only informs
- **Given** an operation in progress
- **When** the order is evaluated
- **Then** Ready, with a note

**Automation:** `MFG WIP Tests.AnUnfinishedOperationOnlyInforms`

## TEST-08 — A check switched off is ignored
- **Given** the missing consumption check off, and consumption missing
- **When** the order is evaluated
- **Then** Ready with no notes

**Automation:** `MFG WIP Tests.ACheckSwitchedOffIsIgnored`

## TEST-09 — The valuation can be replaced
- **Given** a fake valuation implemented through the locator
- **When** an order is evaluated
- **Then** the proposal carries the fake's WIP

**Automation:** `MFG WIP Tests.TheValuationCanBeReplaced`

## TEST-10 — Suggest rebuilds the proposals
- **Given** a stale proposal and a real candidate
- **When** Suggest runs
- **Then** the stale one is gone and the candidate is proposed

**Automation:** `MFG WIP Tests.SuggestRebuildsTheProposals`

## TEST-11 — Finishing a blocked order is refused
- **Given** an order with consumption missing
- **When** it is finished directly, as the API does
- **Then** refused with what the checks found

**Automation:** `MFG WIP Tests.FinishingABlockedOrderIsRefused`

## TEST-12 — Finishing an order with output missing is refused
- **Given** an order with output still missing
- **When** it is finished directly
- **Then** refused

**Automation:** `MFG WIP Tests.FinishingAnOrderWithOutputMissingIsRefused`

## TEST-13 — Ensuring the checks keeps the user's severity
- **Given** the user changed a check's severity
- **When** the checks are ensured again
- **Then** three rows, and the change survives

**Automation:** `MFG WIP Tests.EnsureChecksKeepsTheUsersSeverity`

## TEST-14 — The feature registers a guided setup step
- **When** the feature is asked for its step
- **Then** step 30, with a toggle, opening the feature setup page

**Automation:** `MFG WIP Tests.TheFeatureRegistersAGuidedSetupStep`

## TEST-15 — Importing sample data twice creates it once
- **When** the sample data is imported twice
- **Then** three checks and the configuration package exist

**Automation:** `MFG WIP Tests.ImportingSampleDataTwiceCreatesItOnce`

## TEST-16 — A difference within the tolerance is matched (WIP-002)
- **Given** an order with 30 of WIP in its value entries, a G/L source holding 29.50, tolerance 1
- **When** the order is reconciled
- **Then** value WIP 30, G/L WIP 29.50, difference 0.50, Matched

**Automation:** `MFG WIP Reconciliation Tests.ADifferenceWithinTheToleranceIsMatched`

## TEST-17 — Cost not posted to G/L explains the difference
- **Given** an order with 30 of WIP, nothing in G/L and 30 not posted to G/L
- **When** the order is reconciled
- **Then** Not posted to G/L yet

**Automation:** `MFG WIP Reconciliation Tests.CostNotPostedToGLExplainsTheDifference`

## TEST-18 — An unexplained difference needs investigating
- **Given** an order with 30 of WIP, 10 in G/L and nothing unposted
- **When** the order is reconciled
- **Then** difference 20, Investigate

**Automation:** `MFG WIP Reconciliation Tests.AnUnexplainedDifferenceNeedsInvestigating`

## TEST-19 — Reconcile covers released and recently finished orders
- **Given** reconciliation days 30; a released order, one finished 10 days ago and one 60 days ago
- **When** the reconciliation runs
- **Then** the first two are reconciled, the third is not

**Automation:** `MFG WIP Reconciliation Tests.ReconcileCoversReleasedAndRecentlyFinishedOrders`

## TEST-20 — The default source reads only the WIP accounts
- **Given** a WIP account in the inventory posting setup and an order's value entry related to G/L entries of 30
  on it and 99 on another account; actual cost −50, posted to G/L −20
- **When** the default G/L source reads the order
- **Then** G/L WIP 30, unposted cost −30

**Automation:** `MFG WIP Reconciliation Tests.TheDefaultSourceReadsOnlyTheWipAccounts`

## TEST-21 — Every reconciliation is kept in the history (WIP-003)
- **Given** a released order
- **When** it is reconciled twice with different G/L figures
- **Then** two history entries, the last with the last figure, dated on the work date

**Automation:** `MFG WIP Reconciliation Tests.EveryReconciliationIsKeptInTheHistory`

## TEST-22 — History older than the keep period is removed
- **Given** 90 days kept; entries from 100 and 10 days ago
- **When** the reconciliation runs
- **Then** only the old entry is removed

**Automation:** `MFG WIP Reconciliation Tests.HistoryOlderThanTheKeepPeriodIsRemoved`

## TEST-23 — The scheduled run does nothing while the feature is off
- **Given** the feature off and a reconciliation line from an earlier run
- **When** the scheduled run fires
- **Then** the line is still there

**Automation:** `MFG WIP Reconciliation Tests.TheScheduledRunDoesNothingWhileTheFeatureIsOff`

## TEST-24 — The daily run is found and removed
- **Given** a job queue entry for `MFG WIP Scheduled Run`
- **When** the scheduler is asked, then told to remove the daily run
- **Then** it is scheduled, then it is not

**Automation:** `MFG WIP Reconciliation Tests.TheDailyRunIsFoundAndRemoved`
