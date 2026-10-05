# FEAT-FCL-001 - Finite Loading

## Overview

Business Central plans as if every work center could do any amount of work on any day. Finite loading shows what
really happens when a work center's capacity is respected: in which order its open operations are done, when each one
can start and finish, and which ones will be late. It proposes; it never moves a production order.

## Setup

1. Open **Manufacturing advanced guided setup** and choose **Finite loading**, or search for **Finite loading setup**.
2. Turn on **Enabled**.
3. Set the **Horizon (days)** to load ahead, and choose the **Sequencing**: earliest due date first, order number,
   or shortest operation first.
4. Close the page. Your session restarts once.

The work center needs a calendar: run **Calculate Work Center Calendar** as usual.

## Usage

1. Search for **Finite load plan**, or choose **Finite load plan** on a work center card.
2. Choose the **Work center** and choose **Calculate**.
3. For each open operation you see its place in the sequence, its capacity need, the dates it has now, and the
   **finite** dates it gets when the work center's capacity is respected.
4. Operations marked **Late** finish after their order is due; **Days late** says by how much. An operation that does
   not **fit the horizon** cannot be done within it at all.
5. Choose **Production order** to open the order and act on it.
6. To make the plan the schedule, choose **Apply to orders**. Every operation that fits the horizon moves to its
   finite starting date on the production order, and Business Central reschedules the rest of the order as if you
   had changed the date yourself. This needs **Allow applying the plan to orders** on **Finite loading setup**.
   Calculate again afterwards, because moving one operation also moves the ones after it.

## Notes

- Sample data calculates the load plan of the first work center with open operations; it changes nothing.
