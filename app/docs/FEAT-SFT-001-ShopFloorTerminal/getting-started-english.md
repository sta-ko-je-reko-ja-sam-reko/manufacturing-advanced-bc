# FEAT-SFT-001 - Shop Floor Terminal

## Overview

The shop floor terminal is one page an operator uses at the machine: pick your work center, start and stop the
operation you work on, and report what came out good, what was scrapped and how long the machine stood still. Every
report is posted straight away, so the production order is always up to date.

## Setup

1. Open **Manufacturing advanced guided setup** and choose **Shop floor terminal**, or search for **Shop floor terminal
   setup**.
2. Turn on **Enabled**.
3. Leave **Post run time from the clock** on if the time between Start and Stop should be posted as run time.
4. Optionally choose a **Default scrap code** and **Default stop code**.
5. Close the page. Your session restarts once.

## Usage

### Work on an operation

1. Search for **Shop floor terminal** and choose your **Work center**.
2. Select the operation and choose **Start**. **Running** shows it is yours.
3. When you are done, choose **Stop**. You see how many minutes it ran.

### Report output and scrap

1. Select the operation and choose **Report output**.
2. Enter the **Good quantity**, and the **Scrap quantity** with a **Scrap code** if anything was scrapped.
3. Choose **OK**. The output is posted.

For an order without a routing, open the released production order, select the line, and choose **Report output**.

### Report downtime

1. Select the operation and choose **Report downtime**.
2. Enter the **Minutes** and a **Stop code**, and choose **OK**.

### Look back

Choose **Reported events** to see everything reported from the terminal.

## Notes

- Posting is immediate. To correct a report, post a correction in the output journal as usual.
- Sample data only creates a scrap code and a stop code; it posts nothing.
