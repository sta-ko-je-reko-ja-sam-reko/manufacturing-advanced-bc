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
