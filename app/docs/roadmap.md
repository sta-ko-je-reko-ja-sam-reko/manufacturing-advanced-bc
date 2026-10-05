# Roadmap

The order the candidate modules in [modules.md](modules.md) are built in, and why. Each line is one
feature folder and at least one pull request. A feature may be split into segments; every segment ships
with its tests and its documentation.

| # | Feature | Mark | Status | Why in this position |
|---|---|---|---|---|
| 0 | Foundation | `FEAT-CORE-001` | **Delivered** with the scaffold | Everything else registers through it |
| 1 | Release Pre-flight | `FEAT-PRE-001` | **Delivered**, segment 1 (four checks) | The cheapest guardrail with the most visible pay-off: it turns a posting error a week later into a finding at release. It needs no new master data, only reads standard setup, and hooks one standard flow (`Prod. Order Status Management`, `OnBeforeChangeStatusOnProdOrder`). It also proves the check-and-finding pattern WIP Control and Refresh Protection reuse |
| 2 | WIP Control | `FEAT-WIP-001` | **Delivered**: segment 1 (proposals, checks, finish), segment 2 (G/L reconciliation) | The pitfall with the largest money impact. Its pre-finish checks reuse the pre-flight's check framework |
| 3 | Refresh Protection | `FEAT-RFP-001` | **Delivered**, segment 1 (components and operations) | Small, self-contained, and the pitfall planners complain about most. Hooks `Refresh Production Order` (`OnBeforeCalcRoutingsOrComponents`, `OnAfterRefreshProdOrder`) |
| 4 | Standard Cost Drift | `FEAT-STD-001` | **Delivered**, segment 1 (roll-up and purchase price drift, worksheet, order variances) | Needs only read access to costs and the standard cost worksheet. Most useful once WIP Control has cleaned up the orders that were never finished |
| 5 | Planning Insight | `FEAT-PLN-001` | **Delivered**, segment 1 (history, three rules) | Needs a history of planning runs before it can say anything, so it records first and advises later |
| 6 | Shop Floor Terminal | `FEAT-SFT-001` | **Delivered**, segment 1 (start/stop, output, scrap, downtime) | The first capability module. Posts through the standard output and consumption journals |
| 7 | Engineering Change | `FEAT-ECO-001` | **Delivered**, segment 1 (BOM and routing versions, approval, impact) | Builds on BOM and routing versions; its impact view reuses Refresh Protection's line comparison |
| 8 | Finite Loading | `FEAT-FCL-001` | **Delivered**, segment 1 (one work center, three strategies, proposal only) | The largest and the one closest to established ISVs. Built only as a light, single-constraint engine |

## Rules for every feature

- The feature is switched off after installation, and switching it on is the only thing that changes
  standard behaviour.
- Standard flows are hooked through Microsoft's own events, with subscribers that delegate one line to an
  interface. A blocking check is always configurable down to a warning.
- Nothing posts outside the standard posting routines.
- The tests run on the shared `bc29loc` container next to the owner's other apps, so the app must install
  side by side with them. Its IDs and affix are unique for that reason.
