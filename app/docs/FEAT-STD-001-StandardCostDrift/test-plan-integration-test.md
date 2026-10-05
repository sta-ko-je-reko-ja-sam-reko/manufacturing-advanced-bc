# FEAT-STD-001 - Standard Cost Drift

Integration test plan. Automated in `MFG Cost Drift Integration` (codeunit 89010) with `Library - Inventory` and
`Library - Manufacturing`: real standard-cost items, a certified production BOM, and the standard roll-up.

## TEST-01 — A manufactured item whose roll-up moved is listed and sent with its cost shares
- **Given** a standard-cost item made of two of a component whose standard cost is 10, with its own standard still at 15
- **When** the drift is calculated and the line is sent to the worksheet
- **Then** the roll-up proposes 20, and the worksheet line has new standard cost 20 with single-level and rolled-up
  material cost 20, as Roll Up Standard Cost writes it

**Automation:** `MFG Cost Drift Integration.AManufacturedItemWhoseRollUpMovedIsListedAndSentWithItsCostShares`

## TEST-02 — Implementing the worksheet
- **Given** drift lines sent to the worksheet
- **When** the user runs Implement Standard Cost Changes
- **Then** the items' standard costs change and a revaluation journal is prepared, as with any worksheet line

**Automation:** manual, on `bc29loc`

## TEST-03 — Order variances after cost adjustment
- **Given** a finished production order of a standard-cost item whose consumption differed from the BOM
- **When** costs are adjusted and the order variances are calculated
- **Then** the order shows the material variance

**Automation:** manual, on `bc29loc`
