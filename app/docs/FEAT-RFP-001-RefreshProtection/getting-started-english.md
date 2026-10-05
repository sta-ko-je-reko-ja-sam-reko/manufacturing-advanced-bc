# FEAT-RFP-001 - Refresh Protection

## Overview

When you refresh a production order and recalculate its lines, components or routing, Business Central rebuilds them
from the item, the production BOM and the routing. Anything you changed by hand, such as a quantity, a location, an extra component or
a run time, is lost without a warning. Refresh protection records what each refresh changed, tells you about it, and
lets you put back what you want with one action.

## Setup

1. Open **Manufacturing advanced guided setup** and choose **Refresh protection**, or search for **Refresh protection
   setup**.
2. Turn on **Enabled**. Leave **Notify after a refresh with changes** on to be told straight away.
3. Close the page. Your session restarts once so that the new actions appear.

## Usage

### After a refresh

Refresh a production order as usual. If the refresh changed anything, a notification says how many changes it made.
Choose **Show changes**.

### Review and restore changes

The **Refresh changes** page lists every difference between the order before and after the refresh:

- **Changed**: a value on a component or operation, with the value before and after the refresh.
- **Removed**: a component or operation that existed before the refresh and does not now.
- **Added**: a component or operation the refresh created.

Select the lines you want back and choose **Restore**:

- a changed value goes back to what it was;
- a removed component is created again;
- an added component is deleted.

Changes to the order's own lines are recorded too: a quantity, location, bin or due date you set by hand can be put
back; a different BOM or routing, or a line the refresh removed or added, is shown for information.

Lines where **Restorable** is off are for information only, for example an operation moved to another work centre.
Re-enter those on the order yourself if you need to.

### Look back at earlier refreshes

On a firm planned or released production order, choose **Refresh changes** to see every refresh of that order that
changed something. You can also search for **Production order refreshes**.

## Notes

- Only refreshes made with **Refresh Production Order** are recorded.
- The sample data creates the firm planned order **MFG-RFP-001** with one change a refresh discarded, ready to restore.
