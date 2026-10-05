# FEAT-WIP-001 - WIP Control

## Overview

The cost of a production order is only settled when the order is finished. Orders that stay released after
their last output keep their work in progress on the balance sheet, and their margins stay wrong until someone
notices. WIP control lists those orders, shows how much work in progress each one still holds, checks what would
go wrong if you finished it, and finishes the ones that are ready, all at once.

## Setup

### Switch it on

1. Open **Manufacturing advanced guided setup** and choose **WIP control**, or search for **WIP control setup**.
2. Turn on **Enabled**.
3. Close the page. Your session restarts once so that the new pages and actions appear.

### Settings

On **WIP control setup**:

- **Min. days since last output**: how long an order must have been quiet after its last output before it is
  proposed. Use it to leave time for late consumption or capacity postings.
- **Update unit cost on finish**: update the produced item's unit cost when an order is finished, as the
  *Update Unit Cost* option of *Change Status* does.
- **Checks before finishing**: for each check, choose **Block**, **Inform** or **Off**.
- **Reconciliation tolerance**: the largest difference between the work in progress in the order's entries and in
  the general ledger that still counts as matched.
- **Reconcile orders finished in the last (days)**: finished orders are reconciled for this long after they were
  finished, together with every released one.

## Usage

### Find the orders to finish

1. Search for **Finish proposals**, or choose **Finish proposals** on the **Released Production Orders** list.
2. Choose **Suggest**. Every released order whose output is complete is listed with its estimated work in
   progress, the date of its last output, and what the checks found.
   - **Ready**: nothing stops it.
   - **Blocked**: a check set to *Block* found something; the **Notes** say what. Fix it in the order and choose
     **Suggest** again.

### Finish them

1. Select the orders to finish, or choose **Select all ready**.
2. Choose **Finish selected** and confirm.
3. Each order is finished as if you had changed its status to *Finished* yourself. If one fails, it is marked
   **Failed** with the reason, and the others are still finished.

Choose **Open production order** to look at an order before you decide.

### Reconcile work in progress with the general ledger

1. Search for **WIP reconciliation**, or choose **WIP reconciliation** on **Finish proposals**.
2. Choose **Reconcile**. Every released order, and every order finished recently, is listed with its work in
   progress according to its entries and according to the WIP accounts in the general ledger.
   - **Matched**: the two agree within the tolerance.
   - **Not posted to G/L yet**: the difference is cost that has not been posted to the general ledger. Run
     **Post Inventory Cost to G/L** and reconcile again.
   - **Investigate**: something else explains it, for example a manual journal on the WIP account or a changed
     posting setup.

## Notes

- The estimated work in progress is what the order has consumed and used in capacity, minus the value of its
  output so far. The real figure settles when the order is finished and costs are adjusted.
- Sample data does not post anything. It lists the released orders your company already has whose output is
  complete.
