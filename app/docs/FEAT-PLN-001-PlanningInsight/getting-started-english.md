# FEAT-PLN-001 - Planning Insight

## Overview

When planning moves, changes or cancels the same items' orders run after run, the planning worksheet becomes noise and
planners stop trusting it. The cause is usually a planning parameter on the item. Planning insight remembers the action
messages of every planning run, shows which items keep getting them, and says which parameter to look at.

## Setup

1. Open **Manufacturing advanced guided setup** and choose **Planning insight**, or search for **Planning insight
   setup**.
2. Turn on **Enabled**. Leave **Record after Calculate Plan** on to record every planning run automatically.
3. Set the **Pattern threshold (runs)**: how many runs with the same kind of message make a pattern.
4. Set the **History (days)** to look back over.
5. Under **Patterns to look for**, choose which patterns give advice.
6. Close the page. Your session restarts once.

## Usage

### Build up the history

Run **Calculate Plan** on the planning worksheet as usual. Each run's action messages are recorded. You can also
choose **Record action messages** on the planning worksheet at any time.

### See which items are nervous

1. Choose **Planning insight** on the planning worksheet, or search for it.
2. Choose **Analyze**. For each item you see in how many runs planning proposed a new order, changed a quantity,
   rescheduled or cancelled, together with its current planning parameters.
3. Where a pattern repeats, **Advice** says which parameter to adjust, for example a Dampener Period.
4. Choose **Item card** to change the parameter.

## Notes

- The app never changes a planning parameter itself.
- Sample data records the action messages already on your planning worksheets; it does not run planning.
