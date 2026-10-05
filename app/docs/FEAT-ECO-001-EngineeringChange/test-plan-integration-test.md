# FEAT-ECO-001 - Engineering Change

Integration test plan. Automated in `MFG ECO Integration` (codeunit 89017) with `Library - Manufacturing`.

## TEST-01 — A change creates, approves and certifies a new BOM version
- **Given** a certified production BOM with one component, and a change on it effective tomorrow
- **When** its versions are created, and it is submitted, approved and implemented
- **Then** the BOM gets a version named after the change, first under development with the component copied, then
  certified from the effective date; the change is implemented

**Automation:** `MFG ECO Integration.AChangeCreatesApprovesAndCertifiesANewBomVersion`

## TEST-02 — The impact lists open orders using the BOM
- **Given** a refreshed firm planned order of an item made from a BOM, and a change on that BOM
- **When** the impact is asked for
- **Then** the order is listed

**Automation:** `MFG ECO Integration.TheImpactListsOpenOrdersUsingTheBom`

## TEST-03 — A routing change
- **Given** a certified routing
- **When** a change on it creates, approves and implements a new version
- **Then** the routing version is certified from the effective date

**Automation:** manual, on `bc29loc`

## TEST-04 — Approval through a workflow (ECO-002)
- **Given** an enabled workflow from the template whose specific approver is the current user
- **When** a change is sent for approval and the approver approves it
- **Then** it is pending with one open approval entry carrying its number, then approved by the approver

**Automation:** `MFG ECO Workflow Tests.TheWorkflowApprovesTheChange`

## TEST-05 — Rejection in the workflow
- **Given** a change sent for approval through the workflow
- **When** the approver rejects it
- **Then** the change is open again

**Automation:** `MFG ECO Workflow Tests.RejectingInTheWorkflowReopensTheChange`

## TEST-06 — Reopening cancels the request
- **Given** a change sent for approval through the workflow
- **When** the requester reopens it
- **Then** it is open and has no open approval entry

**Automation:** `MFG ECO Workflow Tests.ReopeningCancelsThePendingRequest`

## TEST-07 — Refreshing the impacted orders (ECO-003)
- **Given** refresh protection on, an implemented change on a certified BOM, and a firm planned order on that BOM due
  after the effective date with a manual change on a component
- **When** the user chooses **Refresh impacted orders**
- **Then** the order's components come from the new version, and the refresh run lists the manual change, which can
  be restored

**Automation:** manual, on `bc29loc`
