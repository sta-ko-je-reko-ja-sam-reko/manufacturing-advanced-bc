# FEAT-PRE-001 - Release Pre-flight

Integration test plan. Automated in `MFG Preflight Integration` (codeunit 89003) with Microsoft's
`Library - Manufacturing` and `Library - Inventory`: real items, a certified production BOM, a refreshed firm
planned order, and the standard status change.

## TEST-01 — Releasing an order with an error is refused
- **Given** pre-flight on and blocking, the routing link check at Error, and a refreshed order whose component
  carries a routing link no operation has
- **When** the order is released through the standard status change
- **Then** the release is refused and the order is still firm planned

**Automation:** `MFG Preflight Integration.ReleasingAnOrderWithAnErrorIsRefused`

## TEST-02 — The same order is released when pre-flight is off
- **Given** the same order with pre-flight switched off
- **When** it is released
- **Then** standard Business Central releases it

**Automation:** `MFG Preflight Integration.ReleasingTheSameOrderWorksWhenThePreflightIsOff`

## TEST-03 — A clean order is released with pre-flight on
- **Given** pre-flight on and blocking, and a refreshed order with nothing wrong with it
- **When** it is released
- **Then** it is released

**Automation:** `MFG Preflight Integration.ACleanOrderIsReleasedWithThePreflightOn`

## TEST-04 — Run pre-flight from the order card
- **Given** the sample order MFG-PRE-001
- **When** the user chooses Run pre-flight on the firm planned order card
- **Then** the findings list opens with the routing link finding

**Automation:** manual, on `bc29loc`

## TEST-05 — The API and MCP configuration
- **Given** the feature enabled
- **When** an agent bound to *Manufacturing Advanced - Release Pre-flight* calls `runPreflight` on
  `preflightOrders` and reads `preflightFindings`
- **Then** the findings of that order are returned; with the feature off, `runPreflight` and a severity change
  are refused

**Automation:** manual, on `bc29loc`
