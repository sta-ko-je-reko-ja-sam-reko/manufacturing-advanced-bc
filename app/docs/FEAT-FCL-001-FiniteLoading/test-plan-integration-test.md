# FEAT-FCL-001 - Finite Loading

Integration test plan. The engine is covered by the unit tests with a fixed capacity source; the default calendar
source is covered by `MFG Loading Tests.TheCalendarSourceSumsTheDaysEntries`. The full flow needs a work center
calendar and refreshed orders with routings, so it is manual.

## TEST-01 — A real work center
- **Given** a work center with a calculated calendar and several refreshed released orders routed through it
- **When** the planner calculates its finite load plan
- **Then** the operations are sequenced by due date, loaded onto the calendar capacity day by day, and those that end
  after their due date are marked late

**Automation:** manual, on `bc29loc`

## TEST-02 — The API
- **Given** the feature enabled
- **When** an agent calls `calculateLoad` on a work center and reads `loadPlanLines`
- **Then** the plan is returned; with the feature off, `calculateLoad` is refused

**Automation:** manual, on `bc29loc`
