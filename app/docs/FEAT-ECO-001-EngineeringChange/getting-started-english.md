# FEAT-ECO-001 - Engineering Change

## Overview

An engineering change order puts a reason, an approval and an effective date around a change to a production BOM or
routing. You make the change in a new version, someone approves it, and on the effective date the new version takes
over. Before you start, you can see which open production orders the change affects.

## Setup

1. Open **Manufacturing advanced guided setup** and choose **Engineering change**. Choose **Create and assign number
   series**, or search for **Engineering change setup** and choose a number series yourself.
2. Turn on **Enabled**.
3. Leave **Approver must differ from requester** on if someone other than the requester must approve.
4. Close the page. Your session restarts once.

## Usage

### Create a change

1. Search for **Engineering change orders** and choose **New**.
2. Enter a **Description**, a **Reason** and the **Effective date**.
3. On the lines, choose the **Type** (Production BOM or Routing), the **No.**, and describe **What changes**.
4. Choose **Create versions**. Each line gets a **New version**, a copy of the version in use. Choose the version to
   open it and make the change.

### See what it affects

Choose **Impact** to see the open production orders that use the BOMs and routings in the change.

### Approve and implement

1. Choose **Send for approval**.
2. The approver opens the change and chooses **Approve** or **Reject**. **Reopen** brings a change back for editing.
3. Choose **Implement**. The new versions are certified from the effective date. Production orders refreshed from then
   on use them.

## Notes

- Only an open or rejected change can be deleted. The versions it created stay.
- The sample data creates the open change **ECO-DEMO-01** with one new BOM version to try out.
