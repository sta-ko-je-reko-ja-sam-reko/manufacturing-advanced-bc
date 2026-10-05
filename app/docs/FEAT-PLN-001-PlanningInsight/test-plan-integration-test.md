# FEAT-PLN-001 - Planning Insight

Integration test plan. Automated in `MFG Planning Integration` (codeunit 89012) with `Library - Planning`, whose
`CalcRegenPlanForPlanWksh` runs the real *Calculate Plan - Plan. Wksh.* report.

## TEST-01 — Calculate Plan records its action messages
- **Given** planning insight on, and an item with a fixed reorder quantity, reorder point 10 and no inventory
- **When** Calculate Plan runs for the item
- **Then** the item's New action message was recorded

**Automation:** `MFG Planning Integration.CalculatePlanRecordsItsActionMessages`

## TEST-02 — Advice over real history
- **Given** an item whose demand moves between planning runs
- **When** Calculate Plan runs several times and the planner chooses Analyze
- **Then** the item shows the rescheduling pattern and its advice

**Automation:** manual, on `bc29loc`
