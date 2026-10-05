# FEAT-PRE-001 - Release Pre-flight

## Overview

Release pre-flight checks a production order before it is released, and catches the problems that would
otherwise only show up later, when consumption or output fails to post:

- a component linked to an operation that is not on the order's routing, so it is never consumed;
- a lot- or serial-tracked component that is flushed automatically but has no lot or serial number assigned;
- a component or output with no bin at a location that requires bins;
- a production BOM or routing that is no longer certified.

You decide, check by check, whether a problem stops the release, only warns, or is ignored.

## Setup

### Switch it on

1. Open **Manufacturing advanced guided setup** and choose **Release pre-flight**, or search for
   **Release pre-flight setup**.
2. Turn on **Enabled**. If you use the guided setup, you can also choose **Load sample data**.
3. Close the page. Your session restarts once so that the new actions appear.

### Decide what happens on release

On **Release pre-flight setup**:

- **Check on release**: run the checks every time an order is released. Turn it off to run them only when
  you choose **Run pre-flight**.
- **Block release on errors**: refuse to release an order that has a problem of severity *Error*.
- **Ask before releasing with warnings**: ask you to confirm when there are warnings.

### Choose the severity of each check

In the **Checks** list on the same page, set each check to **Error**, **Warning** or **Off**.

## Usage

### Release a production order

Release the order as usual, for example with **Change Status** on a firm planned production order.

- If nothing is found, the order is released.
- If something of severity *Error* is found, the release is refused and the message lists what is wrong.
  Fix it, then release again.
- If only warnings are found, you are asked whether to release anyway.

### Check an order before you release it

1. Open a firm planned or released production order.
2. Choose **Run pre-flight**.
3. If something is found, the **Pre-flight findings** list opens, with the most serious problems first.
   Each line says what is wrong, on which line and component, and what to do about it.

To see the result of the last check again, choose **Pre-flight findings** on the order.

## Notes

- When a release is refused, the findings are not kept. Choose **Run pre-flight** to keep them.
- The sample data creates the firm planned order **MFG-PRE-001** with a component linked to an operation that
  does not exist, so you can see a finding straight away.
