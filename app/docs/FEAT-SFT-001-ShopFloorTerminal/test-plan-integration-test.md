# FEAT-SFT-001 - Shop Floor Terminal

Integration test plan. Automated in `MFG Shop Floor Integration` (codeunit 89015) with the standard posting.

## TEST-01 — Reported output is posted to the order
- **Given** the terminal on with the standard posting, and a released order for 3 of an item without a routing
- **When** an operator reports 2 good from the order line
- **Then** an output item ledger entry of 2 is posted and the line's finished quantity is 2

**Automation:** `MFG Shop Floor Integration.ReportedOutputIsPostedToTheOrder`

## TEST-02 — Run time and downtime on a routed operation
- **Given** a released order with a routing on a work center whose capacity unit is minutes
- **When** the operator starts, stops after a few minutes, reports output, and reports downtime
- **Then** the capacity ledger shows the run time and the stop time with the stop code

**Automation:** manual, on `bc29loc`

## TEST-03 — The API
- **Given** the feature enabled
- **When** an agent calls `start`, `stop`, `reportOutput` and `reportDowntime` on `shopFloorOperations`
- **Then** the same postings happen; with the feature off, every action is refused

**Automation:** manual, on `bc29loc`
