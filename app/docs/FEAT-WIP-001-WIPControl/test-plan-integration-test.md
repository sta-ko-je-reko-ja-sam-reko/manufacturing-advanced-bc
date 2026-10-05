# FEAT-WIP-001 - WIP Control

Integration test plan. Automated in `MFG WIP Integration` (codeunit 89005) with `Library - Manufacturing` and
`Library - Inventory`: real items, a certified BOM, a refreshed released order, and posted consumption and output.

## TEST-01 — An order with consumption and output posted is finished
- **Given** a released order whose component was consumed and whose output was posted in full
- **When** its proposal is calculated, selected and Finish selected is chosen
- **Then** the proposal was Ready, one order is finished, the order exists as Finished, and the proposal says Finished

**Automation:** `MFG WIP Integration.AnOrderWithConsumptionAndOutputPostedIsFinished`

## TEST-02 — An order with consumption missing is not finished
- **Given** a released order whose output was posted but whose component was never consumed
- **When** its proposal is calculated, selected and Finish selected is chosen
- **Then** it is Blocked, nothing is finished, and the order stays released

**Automation:** `MFG WIP Integration.AnOrderWithConsumptionMissingIsNotFinished`

## TEST-03 — The worksheet in the client
- **Given** a company with released orders whose output is complete
- **When** the user opens Finish proposals from the Released Production Orders list, chooses Suggest, Select all
  ready and Finish selected
- **Then** the ready orders are finished, and a failure is marked Failed with its reason while the others go ahead

**Automation:** manual, on `bc29loc`

## TEST-04 — The API and MCP configuration
- **Given** the feature enabled
- **When** an agent bound to *Manufacturing Advanced - WIP Control* calls `evaluateFinish` on a released order and
  reads `finishProposals`, then calls `finishOrder`
- **Then** the proposal is returned and the order finished; a blocked order is refused, and with the feature off
  both actions are refused

**Automation:** manual, on `bc29loc`

## TEST-05 — WIP reconciliation against posted entries (WIP-002)
- **Given** a released order with consumption and output posted, and *Post Inventory Cost to G/L* not yet run
- **When** the user chooses **Reconcile**, then runs *Post Inventory Cost to G/L* and chooses **Reconcile** again
- **Then** the order is first *Not posted to G/L yet*, then *Matched*

**Automation:** manual, on `bc29loc`

## TEST-06 — The daily run on the job queue (WIP-003)
- **Given** the feature enabled
- **When** the administrator chooses **Schedule daily run** on the setup, and the job queue entry is run once by hand
- **Then** a recurring entry for *MFG WIP Scheduled Run* exists, and the run refreshes the proposals, the
  reconciliation and adds history entries

**Automation:** manual, on `bc29loc`
