# FEAT-STD-001 - Standard Cost Drift

## Overview

When a BOM, a routing, a work centre's cost or a purchase price changes, the standard cost of the items built from it
stays where it was until someone rolls it up. In the meantime every production order posts a variance. Standard cost
drift shows which items have drifted and by how much, sends the new costs to your standard cost worksheet, and shows
the variances of recently finished production orders by type, so you can see where they come from.

## Setup

1. Open **Manufacturing advanced guided setup** and choose **Standard cost drift**, or search for **Standard cost
   drift setup**.
2. Turn on **Enabled**.
3. Set the **Tolerance %**: an item is listed only when its proposed cost differs from its standard by at least this
   much.
4. Optionally choose the **Standard cost worksheet** to send lines to. If you leave it empty, one called MFG-DRIFT is
   created the first time.
5. Under **Compare standard cost with**, choose which comparisons run: the roll-up of the BOM and routing, the last
   purchase price, and the purchase price lists. A current price list price is used instead of the last purchase
   price, because it is what the item will cost from now on.
6. Close the page. Your session restarts once.

## Usage

### Find the items that have drifted

1. Search for **Standard cost drift**, or choose **Standard cost drift** on the **Standard Cost Worksheet**.
2. Choose **Calculate**. Each listed item shows its current standard cost, the cost proposed today, and the drift.

### Update the standard costs

1. Select the items to update.
2. Choose **Send to worksheet**.
3. Choose **Standard cost worksheet**, review the lines, and use **Implement Standard Cost Changes** as usual.
   Nothing changes on the items until you implement the worksheet.

### See where variances come from

1. Choose **Order variances**, or search for **Production order variances**.
2. Choose **Calculate**. Each production order finished within the variance period is listed with its material,
   capacity and overhead variances. Variances appear only after costs have been adjusted.

## Notes

- Sample data changes no cost and posts nothing. It calculates the drift and the variances of your own company.
